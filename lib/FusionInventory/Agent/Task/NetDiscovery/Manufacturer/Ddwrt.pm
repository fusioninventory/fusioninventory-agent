package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Ddwrt;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/Linux/) {
        my $new_description = $snmp->get('.1.3.6.1.2.1.1.5.0');
        $description = $new_description if $new_description;
    }

    return $description;
}

1;
