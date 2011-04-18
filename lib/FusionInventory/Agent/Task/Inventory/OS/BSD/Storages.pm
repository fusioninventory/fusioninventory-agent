package FusionInventory::Agent::Task::Inventory::OS::BSD::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return -r '/etc/fstab';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get a list of devices from /etc/fstab
    my $handle = getFileHandle(file => '/etc/fstab', logger => $logger);
    return unless $handle;

    my @devices;
    while (<$handle>) {
        next unless m{/^/dev/(\S+)};
        push @devices, $1;
    }
    close $handle;

    #  filter duplicates
    my %seen;
    @devices = grep { !$seen{$_}++ } @devices;

    # parse dmesg
    foreach my $device (@devices) {
        my ($model, $capacity, $manufacturer);
        foreach (`dmesg`){
            if(/^$device.*<(.*)>/) { $model = $1; }
            if(/^$device.*\s+(\d+)\s*MB/) { $capacity = $1;}
        }

        if ($model) {
            if ($model =~ s/^(SGI|SONY|WDC|ASUS|LG|TEAC|SAMSUNG|PHILIPS|PIONEER|MAXTOR|PLEXTOR|SEAGATE|IBM|SUN|SGI|DEC|FUJITSU|TOSHIBA|YAMAHA|HITACHI|VERITAS)\s*//i) {
                $manufacturer = $1;
            }

            # clean up the model
            $model =~ s/^(\s|,)*//;
            $model =~ s/(\s|,)*$//;
        }

        $inventory->addStorage({
            MANUFACTURER => $manufacturer,
            MODEL => $model,
            DESCRIPTION => $device,
            DISKSIZE => $capacity
        });
    }
}

1;
