package FusionInventory::Agent::Task::Inventory::Win32::Slots;

use strict;
use warnings;

# Had never been tested. There is no slot on my virtal machine.
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWMIObjects(
        class      => 'Win32_SystemSlot',
        properties => [ qw/Name Description SlotDesignation Status/ ]
    )) {

        $inventory->addEntry(
            section => 'SLOTS',
            entry   => {
                NAME        => $object->{Name},
                DESCRIPTION => $object->{Description},
                DESIGNATION => $object->{SlotDesignation},
                STATUS      => $object->{Status},
            }
        );
    }

}

1;
