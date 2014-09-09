package FusionInventory::Agent::Task::Inventory::Win32::Slots;

use strict;

use FusionInventory::Agent::Tools::Win32;

my %status = (
    3 => 'free',
    4 => 'used'
);

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWMIObjects(
        class      => 'Win32_SystemSlot',
        properties => [ qw/Name Description SlotDesignation CurrentUsage/ ]
    )) {

        $inventory->addEntry(
            section => 'SLOTS',
            entry   => {
                NAME        => $object->{Name},
                DESCRIPTION => $object->{Description},
                DESIGNATION => $object->{SlotDesignation},
                STATUS      => $status{$object->{CurrentUsage}}
            }
        );
    }

}

1;
