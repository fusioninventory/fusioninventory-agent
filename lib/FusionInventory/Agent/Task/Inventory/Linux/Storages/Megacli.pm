package FusionInventory::Agent::Task::Inventory::Linux::Storages::Megacli;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

our $megacli = "megacli";

sub isEnabled {
    return canRun($megacli);
}

#
# The module gets a disk data from `megacli -PDlist` and `megacli -ShowSummary`.
# `PDlist` provides s/n and model in a single 'Inquiry Data' string, and 
# `ShowSummary` helps to "separate the wheat from the chaff". (Wish there was 
# an easier way).
#
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my (%adapter, %summary, %pdlist, $storage);
    my $AdaptersTotal = _getAdpCount();
    return unless $AdaptersTotal;

    for (my $adp = 0; $adp < $AdaptersTotal; $adp++) {
        $adapter{$adp} = _getAdpEnclosure( adp => $adp );
        $summary{$adp} = _getSummary( adp => $adp );
        $pdlist{$adp}  = _getPDlist( adp => $adp );
    }

    while (my ($adp_id, $adp) =  each %adapter) {
        while (my ($pd_id, $pd) = each %{$pdlist{$adp_id}}) {
            my ($firmware, $serial, $size, $model, $vendor);

            ($size) = ($pd->{'Raw Size'} =~ /^(.+) \[/);       # Raw Size: 232.885 GB [0x1d1c5970 Sectors]
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
                if ($adp->{$sum->{encl_id}} == $pd->{'Enclosure Device ID'} &&
                    $sum->{encl_pos}        == $pd->{'Enclosure position'} &&
                    $sum->{slot}            == $pd->{'Slot Number'}
                ){
                    $model  = $sum->{'Product Id'};            # $model  = 'HUC101212CSS'  <-- note it is incomplete
                    $serial = $pd->{'Inquiry Data'};           # $serial = 'HGST    HUC101212CSS600 U5E0KZGLG2HE'
                    $serial =~ s/$firmware//;                  # $serial = 'HGST    HUC101212CSS600 KZGLG2HE'

                    unless ($sum->{'Vendor Id'} =~ /^ATA$/) {
                        $vendor = $sum->{'Vendor Id'};
                        $serial =~ s/$vendor//;                # $serial = '    HUC101212CSS600 KZGLG2HE'
                    }

                    $serial =~ s/$model[^ ]*//;                # $serial = '     KZGLG2HE'
                    $serial =~ s/\s//g;                        # $serial = 'KZGLG2HE'
                    $storage->{SERIALNUMBER} = $serial;

                    # Restore complete model name:  HUC101212CSS --> HUC101212CSS600
                    if ($pd->{'Inquiry Data'} =~ /($sum->{'Product Id'}(?:[^ ]*))/) {
                        $model = $1;
                        $model =~ s/^\s+//;
                        $model =~ s/\s+$//;
                    }
                }
            }

            # When Product ID ($model) looks like 'INTEL SSDSC2CW24'
            if ($model =~ /^(\S+)\s+(\S+)$/) {
                $vendor = $1;        # 'INTEL'
                $model  = $2;        # 'SSDSC2CW24'
            }

            $storage->{NAME}  = $model;
            $storage->{MODEL} = $model;
            $storage->{MANUFACTURER} = 
	            (defined $vendor) ? getCanonicalManufacturer($vendor) : getCanonicalManufacturer($model);

            $inventory->addEntry(
                section => 'STORAGES',
                entry   => $storage,
            );
        }
    }
}

sub _getAdpCount {
    my $handle = getFileHandle(command => "$megacli -adpCount");
    return unless $handle;

    my $adp_count;
    while (<$handle>) {
        chomp;
        next unless /Controller Count: (\d+)/;
        $adp_count = $1;
        last;
    }
    close $handle;

    return $adp_count;
}

sub _getAdpEnclosure {
    my (%params) = @_;

    my %enclosure;
    my $handle = getFileHandle(command => "$megacli -EncInfo -a$params{adp}");
    return unless $handle;

    my $encl_id;
    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ /Enclosure (\d+):/) {
            $encl_id = $1;
        }
        next unless defined $encl_id;

        if ($line =~ /Device ID\s+:\s+(\d+)/) {
            $enclosure{$encl_id} = $1;
        }
    }
    close $handle;

    return \%enclosure;
}

sub _getSummary {
    my (%params) = @_;

    my $adp = $params{'adp'};
    my %drive;

    my $handle = getFileHandle(command => "$megacli -ShowSummary -a$adp");
    return unless $handle;

    my $PD; my $n = -1;
    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ /^\s+PD\s+$/) {
            $PD = 1;
        }
        next unless $PD;

        $n++ if $line =~ /Connector\s*:/;

        if ($line =~ /Connector\s*:\s*(\d+)(?:<Internal>)?<Encl Pos (\d+) >: Slot (\d+)/) {
            $drive{$n} = {
                encl_id  => $1,
                encl_pos => $2,
                slot     => $3,
            };
            $drive{$n}->{'encl_id'} += 0;  # drop leading zeroes
        } elsif ($line =~ /^\s*(.+[^ ])\s*:\s*(.+[^ ])/) {
            $drive{$n}->{$1} = $2;
        }
    }
    close $handle;

    #delete non-disks
    foreach my $i (keys %drive) { delete $drive{$i} unless defined $drive{$i}->{'slot'}; }

    return \%drive;
}

sub _getPDlist {
    my (%params) = @_;

    my $adp = $params{'adp'};
    my %pdlist;

    my $handle = getFileHandle(command => "$megacli -PDlist -a$adp");
    return unless $handle;

    my $n = 0; my $key; my $val;
    while (<$handle>) {
        chomp;
        next unless /^([^:]+)\s*:\s*(.+[^ ])/;
        $key = $1;
        $val = $2;
        $n++ if $key =~ /Enclosure Device ID/;
        $pdlist{$n}->{$key} = $val;
    }
    close $handle;

    return \%pdlist;
}

1;
