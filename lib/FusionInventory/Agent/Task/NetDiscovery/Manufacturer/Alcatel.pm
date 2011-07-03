package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Alcatel;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    # example : 5.1.6.485.R02 Service Release, September 26, 2008.
    return unless $description =~ m/^([1-9]{1}).([0-9]{1}).([0-9]{1})(.*) Service Release,(.*)([0-9]{1}).$/;

    my $result = $snmp->get('.1.3.6.1.2.1.47.1.1.1.1.13.1');
    return $result eq "OS66-P24" ? "OmniStack 6600-P24" : $result;
}

1;
