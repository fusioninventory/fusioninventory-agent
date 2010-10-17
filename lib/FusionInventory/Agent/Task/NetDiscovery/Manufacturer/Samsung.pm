package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Samsung;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.4.1.236.11.5.1.1.1.1.0');
}

1;
