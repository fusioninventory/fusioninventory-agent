package FusionInventory::Agent::Task::Inventory::Linux::LXC;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $hardware  = _getLibvirtLXC_UUID(logger => $logger);

    $inventory->setHardware($hardware) if $hardware;
}


1;
