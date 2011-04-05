package FusionInventory::Agent::Task::Inventory::OS::Win32::Slots;

use strict;
use warnings;

# Had never been tested. There is no slot on my virtal machine.
use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_SystemSlot',
        properties => [ qw/
            Name Description SlotDesignation Status Shared
        / ]
    )) {

        $inventory->addSlot({
            NAME        => $object->{Name},
            DESCRIPTION => $object->{Description},
            DESIGNATION => $object->{SlotDesignation},
            STATUS      => $object->{Status},
            SHARED      => $object->{Shared}
        });
    }

}

1;
