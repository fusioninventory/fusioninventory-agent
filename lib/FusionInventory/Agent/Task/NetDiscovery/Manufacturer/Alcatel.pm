package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Alcatel;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    # example : 5.1.6.485.R02 Service Release, September 26, 2008.

    if ($description =~ m/^([1-9]{1}).([0-9]{1}).([0-9]{1})(.*) Service Release,(.*)([0-9]{1}).$/) {
        my $new_description = $snmp->get('.1.3.6.1.2.1.47.1.1.1.1.13.1');
        if ($new_description) {
            $description = $new_description eq "OS66-P24" ?
                "OmniStack 6600-P24" : $new_description;
        }
    }

    return $description;
}

1;
