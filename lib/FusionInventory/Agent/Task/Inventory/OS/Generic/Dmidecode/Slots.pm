package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $slots = _getSlots($logger);

    return unless $slots;

    foreach my $slot (@$slots) {
        $inventory->addSlots($slot);
    }
}

sub _getSlots {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode($logger, $file);

    return unless $infos->{9};

    my $slots;
    foreach my $info (@{$infos->{9}}) {
        my $slot = {
            DESCRIPTION => $info->{'Type'},
            DESIGNATION => $info->{'ID'},
            NAME        => $info->{'Designation'},
            STATUS      => $info->{'Current Usage'},
        };

        cleanUnknownValues($slot);

        push @$slots, $slot;
    }

    return $slots;
}

1;
