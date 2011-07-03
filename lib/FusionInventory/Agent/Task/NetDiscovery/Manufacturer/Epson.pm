package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Epson;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if($description =~ m/EPSON Built-in/) {
        my $description_new = $snmp->get('.1.3.6.1.4.1.1248.1.1.3.1.3.8.0');
        if ($description_new ne "null") {
            $description = $description_new;
        }
    }

    if($description =~ m/EPSON Internal 10Base-T/) {
        my $description_new = $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
        if ($description_new ne "null") {
            $description = $description_new;
        }
    }

    return $description;
}

1;
