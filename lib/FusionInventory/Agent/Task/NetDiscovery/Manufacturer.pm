package FusionInventory::Agent::Task::NetDiscovery::Manufacturer;

use strict;
use warnings;

sub setDescription {
    my ($device, $snmp, $oid) = @_;

    return $snmp->get('.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0');
}

sub setVendor {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0');
}

1;
