package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Ddwrt;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.2.1.1.5.0');
}

1;
