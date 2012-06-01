package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $slot (_getSlots(logger => $logger)) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $parser = getDMIDecodeParser(@_);

    my @slots;
    foreach my $handle ($parser->get_handles(dmitype => 9)) {
        my $slot = {
            DESCRIPTION => getSanitizedValue($handle, 'slot-type'),
            DESIGNATION => getSanitizedValue($handle, 'slot-id'),
            NAME        => getSanitizedValue($handle, 'slot-designation'),
            STATUS      => getSanitizedValue($handle, 'slot-current-usage'),
        };

        push @slots, $slot;
    }

    return @slots;
}

1;
