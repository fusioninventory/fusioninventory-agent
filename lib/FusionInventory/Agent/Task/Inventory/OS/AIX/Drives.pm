package FusionInventory::Agent::Task::Inventory::OS::AIX::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run("df");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    # get drives list
    my @drives =
        getFilesystemsFromDf(logger => $logger, command => 'df -P -k');

    # get additional informations
    foreach my $drive (@drives) {
        my @lines = getAllLines(
            logger => $logger, command => "lsfs -c $drive->{TYPE}"
        );
        my @info = split /:/, $lines[1];     
        $drive->{FILESYSTEM} = $info[2];
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
