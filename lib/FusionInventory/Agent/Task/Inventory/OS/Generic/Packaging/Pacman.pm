package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Pacman;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("/usr/bin/pacman");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach(`/usr/bin/pacman -Q`){
        /^(\S+)\s+(\S+)/;
        my $name = $1;
        my $version = $2;

        $inventory->addSoftware({
            'NAME' => $name,
            'VERSION' => $version
        });
    }
}

1;
