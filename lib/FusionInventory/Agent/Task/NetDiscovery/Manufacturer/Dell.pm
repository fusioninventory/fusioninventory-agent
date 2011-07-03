package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Dell;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    return unless $description =~ m/^Ethernet Switch$/;
    return $snmp->get('.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0');
}

1;
