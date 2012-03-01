package FusionInventory::Agent::Task::Inventory::Input::Win32::Environment;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{environment};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_Environment',
        properties => [ qw/SystemVariable Name VariableValue/ ]
    )) {

        next unless $object->{SystemVariable};

        $inventory->addEntry(
            section => 'ENVS',
            entry   => {
                KEY => $object->{Name},
                VAL => $object->{VariableValue}
            }
        );
    }
}

1;
