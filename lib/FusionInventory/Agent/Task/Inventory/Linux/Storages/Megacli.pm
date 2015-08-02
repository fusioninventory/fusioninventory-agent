package FusionInventory::Agent::Task::Inventory::Linux::Storages::Megacli;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('megacli');
}

# The module gets a disk data from `megacli -PDlist` and `megacli -ShowSummary`.
# `PDlist` provides s/n and model in a single 'Inquiry Data' string, and
# `ShowSummary` helps to "separate the wheat from the chaff". (Wish there was
# an easier way).
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $count = getFirstMatch(
        command => "megacli -adpCount",
        pattern => qr/Controller Count: (\d+)/
    );
    return unless $count;

    my (%adapter, %summary, %pdlist, $storage);
    for (my $adp = 0; $adp < $count; $adp++) {
        $adapter{$adp} = _getAdpEnclosure( adp => $adp );
        $summary{$adp} = _getSummary( adp => $adp );
        $pdlist{$adp}  = _getPDlist( adp => $adp );
    }

    while (my ($adp_id, $adp) =  each %adapter) {
        while (my ($pd_id, $pd) = each %{$pdlist{$adp_id}}) {
            my ($firmware, $size, $model, $vendor);

            # Raw Size: 232.885 GB [0x1d1c5970 Sectors]
            ($size) = ($pd->{'Raw Size'} =~ /^(.+)\s\[/);
            $size = getCanonicalSize($size);
            $firmware = $pd->{'Device Firmware Level'};

            $storage = {
                TYPE         => 'disk',
                FIRMWARE     => $firmware,
                DESCRIPTION  => $pd->{'PD Type'},
                DISKSIZE     => $size,
            };

            # Lookup the disk info in 'ShowSummary'
            while (my ($sum_id, $sum) = each %{$summary{$adp_id}}) {
                next unless
                    $adp->{$sum->{encl_id}} == $pd->{'Enclosure Device ID'} &&
                    $sum->{encl_pos}        eq $pd->{'Enclosure position'} &&
                    $sum->{slot}            == $pd->{'Slot Number'};

                # 'HUC101212CSS'  <-- note it is incomplete
                $model  = $sum->{'Product Id'};

                # 'HGST    HUC101212CSS600 U5E0KZGLG2HE'
                my $serial = $pd->{'Inquiry Data'};
                $serial =~ s/$firmware//;        # remove firmware part

                if ($sum->{'Vendor Id'} ne 'ATA') {
                    $vendor = $sum->{'Vendor Id'};
                    $serial =~ s/$vendor//;      # remove vendor part
                }

                $serial =~ s/$model\S*//;      # remove model part
                $serial =~ s/\s//g;              # remove remaining spaces
                $storage->{SERIALNUMBER} = $serial;

                # Restore complete model name:
                # HUC101212CSS --> HUC101212CSS600
                if ($pd->{'Inquiry Data'} =~ /($sum->{'Product Id'}(?:\S*))/) {
                    $model = $1;
                    $model =~ s/^\s+//;
                    $model =~ s/\s+$//;
                }

                last;
            }

            # When Product ID ($model) looks like 'INTEL SSDSC2CW24'
            if ($model =~ /^(\S+)\s+(\S+)$/) {
                $vendor = $1;        # 'INTEL'
                $model  = $2;        # 'SSDSC2CW24'
            }

            $storage->{NAME}  = $model;
            $storage->{MODEL} = $model;
            $storage->{MANUFACTURER} = defined $vendor ?
                getCanonicalManufacturer($vendor) :
                getCanonicalManufacturer($model);

            $inventory->addEntry(
                section => 'STORAGES',
                entry   => $storage,
            );
        }
    }
}

sub _getAdpEnclosure {
    my (%params) = @_;

    my $command = exists $params{adp} ? "megacli -EncInfo -a$params{adp}" : undef;

    my $handle = getFileHandle(
        command => $command,
        %params
    );
    return unless $handle;

    my %enclosure;
    my $encl_id;
    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /Enclosure (\d+):/) {
            $encl_id = $1;
        }

        if ($line =~ /Device ID\s+:\s+(\d+)/) {
            $enclosure{$encl_id} = $1;
        }
    }
    close $handle;

    return \%enclosure;
}

sub _getSummary {
    my (%params) = @_;

    my $command = exists $params{adp} ? "megacli -ShowSummary -a$params{adp}" : undef;

    my $handle = getFileHandle(
        command => $command,
        %params
    );
    return unless $handle;

    # fast forward to relevant section
    while (my $line = <$handle>) {
        last if $line =~ /^\s+PD\s+$/;
    }

    my %drive;
    my $n = -1;
    while (my $line = <$handle>) {
        # end of relevant section
        last if $line =~ /^Storage$/;
        chomp $line;

        $n++ if $line =~ /Connector\s*:/;

        if ($line =~ /Connector\s*:\s*(\d+)(?:<Internal>)?<Encl Pos (\d+) >: Slot (\d+)/) {
            $drive{$n} = {
                encl_id  => $1,
                encl_pos => $2,
                slot     => $3,
            };
            $drive{$n}->{'encl_id'} += 0;  # drop leading zeroes
        } elsif ($line =~ /^\s*(.+\S)\s*:\s*(.+\S)/) {
            $drive{$n}->{$1} = $2;
        }
    }
    close $handle;

    #delete non-disks
    foreach my $i (keys %drive) {
        delete $drive{$i} unless defined $drive{$i}->{'slot'};
    }

    return \%drive;
}

sub _getPDlist {
    my (%params) = @_;

    my $command = exists $params{adp} ? "megacli -PDlist -a$params{adp}" : undef;

    my $handle = getFileHandle(
        command => $command,
        %params
    );
    return unless $handle;

    my %pdlist;
    my $n = 0;
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /^([^:]+)\s*:\s*(.*\S)/;
        my $key = $1;
        my $val = $2;
        $n++ if $key =~ /Enclosure Device ID/;
        $pdlist{$n}->{$key} = $val;
    }
    close $handle;

    return \%pdlist;
}

1;
