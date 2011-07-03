package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Samsung;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if($description =~ m/SAMSUNG NETWORK PRINTER,ROM/) {
        my $description_new = $snmp->get('.1.3.6.1.4.1.236.11.5.1.1.1.1.0');
        if ($description_new ne "null") {
            $description = $description_new;
        }
    }
    return $description;
}

1;
