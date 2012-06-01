package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Ports;

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

    foreach my $port (_getPorts(logger => $logger)) {
        $inventory->addEntry(
            section => 'PORTS',
            entry   => $port
        );
    }
}

sub _getPorts {
    my $parser = getDMIDecodeParser(@_);

    my @ports;
    foreach my $handle ($parser->get_handles(dmitype => 8)) {
        my $port = {
            CAPTION     => getSanitizedValue(
                $handle, 'connector-external-connector-type'),
            DESCRIPTION => getSanitizedValue(
                $handle, 'connector-internal-connector-type'),
            NAME        => getSanitizedValue(
                $handle, 'connector-internal-reference-designator'),
            TYPE        => getSanitizedValue(
                $handle, 'connector-port-type'),
        };

        push @ports, $port;
    }

    return @ports;
}

1;
