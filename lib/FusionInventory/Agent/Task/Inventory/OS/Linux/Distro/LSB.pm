package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("lsb_release");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $release = getFirstMatch(
        logger  => $logger,
        command => 'lsb_release -d',
        pattern => qr/Description:\s+(.+)/
    );

    $inventory->setHardware({
        OSNAME     => $release,
    });
}

1;
