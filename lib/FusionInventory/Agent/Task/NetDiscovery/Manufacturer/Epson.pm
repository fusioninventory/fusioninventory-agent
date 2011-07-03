package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Epson;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/EPSON Built-in/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.1248.1.1.3.1.3.8.0');
        $description = $new_description if $new_description;
    }

    if ($description =~ m/EPSON Internal 10Base-T/) {
        my $new_description = $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
        $description = $new_description if $new_description;
    }

    return $description;
}

1;
