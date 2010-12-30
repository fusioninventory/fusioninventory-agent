package FusionInventory::Agent::Task::Inventory::OS::AIX::Drives;

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

    my @drives = getFilesystemsFromDf(
        logger => $logger,
	string => getDfoutput
    );
    foreach my $drive (@drives) {
        my @fs = `lsfs -c $drive->{TYPE}`;
        my @fstype = split /:/, $fs[1];     
        $drive->{FILESYSTEM} = $fstype[2];
        $inventory->addDrive($drive);
    }
}

1;
