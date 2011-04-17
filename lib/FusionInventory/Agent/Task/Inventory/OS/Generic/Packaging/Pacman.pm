package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Pacman;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("/usr/bin/pacman");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};


    my $handle = getFileHandle(
        logger => $logger,
        command => '/usr/bin/pacman -Q'
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)\s+(\S+)/;
        my $name = $1;
        my $version = $2;

        $inventory->addSoftware({
            NAME    => $name,
            VERSION => $version
        });
    }
    close $handle;
}

1;
