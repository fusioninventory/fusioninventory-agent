package FusionInventory::Agent::Task::Inventory::BSD::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{drive};
    return canRun('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystem types
    my @types =
        grep { ! /^(?:fdesc|devfs|procfs|linprocfs|linsysfs|tmpfs|fdescfs)$/ }
        getFilesystemsTypesFromMount(logger => $logger);

    # get filesystem for each type
    my @filesystems;
    foreach my $type (@types) {
        push @filesystems, getFilesystemsFromDf(
            logger  => $logger,
            command => "df -P -k -t $type",
            type    => $type
        );
    }

    # add filesystems to the inventory
    foreach my $filesystem (@filesystems) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $filesystem
        );
    }
}

1;
