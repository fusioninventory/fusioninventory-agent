package FusionInventory::Agent::Task::Inventory::Generic::Softwares::Pacman;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('pacman');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'pacman -Q'
    );
    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)\s+(\S+)/;
        my $name = $1;
        my $version = $2;

       $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => {
                NAME    => $name,
                VERSION => $version
            }
        );
    }
    close $handle;
}

1;
