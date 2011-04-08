package FusionInventory::Agent::Task::Inventory::OS::Win32::Environment;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_Environment',
        properties => [ qw/SystemVariable Name VariableValue/ ]
    )) {

        next unless $object->{SystemVariable};

        $inventory->addEntry({
            section => 'ENVS',
            entry   => {
                KEY => $object->{Name},
                VAL => $object->{VariableValue}
            }
        });
    }
}

1;
