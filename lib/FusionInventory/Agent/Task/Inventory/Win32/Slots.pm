package FusionInventory::Agent::Task::Inventory::Win32::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

my %status = (
    3 => 'free',
    4 => 'used'
);

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{slot};
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
