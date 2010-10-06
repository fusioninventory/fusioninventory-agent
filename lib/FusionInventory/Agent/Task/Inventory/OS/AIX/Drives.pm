package FusionInventory::Agent::Task::Inventory::OS::AIX::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("df");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $drives = getFilesystemsFromDf($logger, 'df -P -k', '-|');
    foreach my $drive (@$drives) {
        my @fs = `lsfs -c $drive->{TYPE}`;
        my @fstype = split /:/, $fs[1];     
        $drive->{FILESYSTEM} = $fstype[2];
    }

    foreach my $drive (@$drives) {
        $inventory->addDrive($drive);
    }
}

1;
