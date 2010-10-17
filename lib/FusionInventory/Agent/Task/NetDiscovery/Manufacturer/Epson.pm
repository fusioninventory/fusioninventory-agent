package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Epson;

use strict;
use warnings;

sub getDescriptionBuiltin {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.4.1.1248.1.1.3.1.3.8.0');
}

sub getDescriptionInternal {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
}

1;
