package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Epson;

use strict;
use warnings;

sub getBetterDescription {
    my ($description, $snmp) = @_;

    if ($description =~ m/EPSON Built-in/) {
        return $snmp->get('.1.3.6.1.4.1.1248.1.1.3.1.3.8.0');
    }

    if ($description =~ m/EPSON Internal 10Base-T/) {
        return $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
    }

    return;
}

1;
