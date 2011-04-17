package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get drives list
    my @types = 
        grep { ! /^(?:fdesc|devfs|procfs|linprocfs|linsysfs|tmpfs|fdescfs)$/ }
        getFilesystemsTypesFromMount(logger => $logger);

    my @drives;
    foreach my $type (@types) {
        push @drives, getFilesystemsFromDf(
            logger => $logger,
            command => "df -P -k -t $type"
        );
    }

    # add drives to the inventory
    foreach my $drive (@drives) {
        $inventory->addEntry({
            section => 'DRIVES',
            entry   => $drive
        });
    }
}

1;
