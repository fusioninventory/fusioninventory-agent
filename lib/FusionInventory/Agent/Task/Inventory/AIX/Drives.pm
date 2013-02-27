package FusionInventory::Agent::Task::Inventory::AIX::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return canRun('df');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get filesystems
    my @filesystems =
        getFilesystemsFromDf(logger => $logger, command => 'df -P -k');

    # get additional informations
    foreach my $filesystem (@filesystems) {
        my @lines = getAllLines(
            logger => $logger, command => "lsfs -c $filesystem->{TYPE}"
        );
        my @info = split /:/, $lines[1];
        $filesystem->{FILESYSTEM} = $info[2];
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
