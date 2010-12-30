package FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @ffs_drives = getFilesystemsFromDf(
        logger => $logger,
        string => getDfoutput 
    );
    foreach my $drive (@ffs_drives) {
        $inventory->addDrive($drive);
    }
}

1;
