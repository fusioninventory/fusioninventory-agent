package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $slots = getPorts();

    return unless $slots;

    foreach my $slot (@$slots) {
        $inventory->addSlots($slot);
    }
}

sub getSlots {
    my ($file) = @_;

    my $infos = getInfoFromDmidecode($file);

    return unless $infos->{9};

    my $slots;
    foreach my $info (@{$infos->{9}}) {
        my $slot = {
            DESCRIPTION => $info->{'Type'},
            DESIGNATION => $info->{'ID'},
            NAME        => $info->{'Designation'},
            STATUS      => $info->{'Current Usage'},
        };

        foreach my $key (keys %$slot) {
           delete $slot->{$key} if !defined $slot->{$key};
        }

        push @$slots, $slot;
    }

    return $slots;
}

1;
