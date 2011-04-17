package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $slots = _getSlots($logger);

    return unless $slots;

    foreach my $slot (@$slots) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode(logger => $logger, file => $file);

    return unless $infos->{9};

    my $slots;
    foreach my $info (@{$infos->{9}}) {
        my $slot = {
            DESCRIPTION => $info->{'Type'},
            DESIGNATION => $info->{'ID'},
            NAME        => $info->{'Designation'},
            STATUS      => $info->{'Current Usage'},
        };

        push @$slots, $slot;
    }

    return $slots;
}

1;
