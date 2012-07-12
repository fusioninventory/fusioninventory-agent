package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Alcatel;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.2.1.47.1.1.1.1.13.1');
    return $result eq "OS66-P24" ? "OmniStack 6600-P24" : $result;
}

1;
