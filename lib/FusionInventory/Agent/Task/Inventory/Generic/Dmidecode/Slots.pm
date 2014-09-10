package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

my %status = (
    'Unknown'   => undef,
    'In Use'    => 'used',
    'Available' => 'free'
);

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{slot};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $slots = _getSlots(logger => $logger);

    return unless $slots;

    foreach my $slot (@$slots) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{9};

    my $slots;
    foreach my $info (@{$infos->{9}}) {
        my $slot = {
            DESCRIPTION => $info->{'Type'},
            DESIGNATION => $info->{'ID'},
            NAME        => $info->{'Designation'},
            STATUS      => $info->{'Current Usage'} ?
                $status{$info->{'Current Usage'}} : undef,
        };

        push @$slots, $slot;
    }

    return $slots;
}

1;
