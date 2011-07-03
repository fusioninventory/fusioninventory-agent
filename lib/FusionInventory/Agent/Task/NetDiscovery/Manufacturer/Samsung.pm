package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Samsung;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/SAMSUNG NETWORK PRINTER,ROM/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.236.11.5.1.1.1.1.0');
        $description = $new_description if $new_description;
    }

    return $description;
}

1;
