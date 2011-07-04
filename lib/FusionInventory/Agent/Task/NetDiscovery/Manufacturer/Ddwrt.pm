package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Ddwrt;

use strict;
use warnings;

sub getBetterDescription {
    my ($description, $snmp) = @_;

    return unless $description =~ m/Linux/;
    return $snmp->get('.1.3.6.1.2.1.1.5.0');
}

1;
