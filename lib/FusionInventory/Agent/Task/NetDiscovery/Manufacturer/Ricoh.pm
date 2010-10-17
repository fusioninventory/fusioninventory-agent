package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Ricoh;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
}

1;
