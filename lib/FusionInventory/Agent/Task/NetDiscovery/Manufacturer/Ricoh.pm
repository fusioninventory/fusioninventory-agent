package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Ricoh;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/RICOH NETWORK PRINTER/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
        $description = $new_description if $new_description;
    }

    return $description;
}

1;
