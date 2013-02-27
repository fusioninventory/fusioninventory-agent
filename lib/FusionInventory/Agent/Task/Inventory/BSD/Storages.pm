package FusionInventory::Agent::Task::Inventory::BSD::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return -r '/etc/fstab';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get a list of devices from /etc/fstab
    my @devices = _getDevicesFromFstab(logger => $logger);

    # parse dmesg
    my @lines = getAllLines(
        command => 'dmesg'
    );

    foreach my $device (@devices) {

        foreach my $line (@lines) {
            if ($line =~ /^$device->{DESCRIPTION}.*<(.*)>/) {
                $device->{MODEL} = $1;
            }
            if ($line =~ /^$device->{DESCRIPTION}.*\s+(\d+)\s*MB/) {
                $device->{CAPACITY} = $1;
            }
        }

        if ($device->{MODEL}) {
            if ($device->{MODEL} =~ s/^(SGI|SONY|WDC|ASUS|LG|TEAC|SAMSUNG|PHILIPS|PIONEER|MAXTOR|PLEXTOR|SEAGATE|IBM|SUN|SGI|DEC|FUJITSU|TOSHIBA|YAMAHA|HITACHI|VERITAS)\s*//i) {
                $device->{MANUFACTURER} = $1;
            }

            # clean up the model
            $device->{MODEL} =~ s/^(\s|,)*//;
            $device->{MODEL} =~ s/(\s|,)*$//;
        }

        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $device
        );
    }
}

sub _getDevicesFromFstab {
    my (%params) = (
        file => '/etc/fstab',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my (@devices, %seen);
    while (my $line = <$handle>) {
        next unless $line =~ m{^/dev/(\S+)};
        next if $seen{$1}++;
        push @devices, { DESCRIPTION => $1 };
    }
    close $handle;

    return @devices;
}

1;
