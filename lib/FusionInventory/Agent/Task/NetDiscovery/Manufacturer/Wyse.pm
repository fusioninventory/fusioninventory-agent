package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Wyse;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/Linux/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.714.1.2.5.6.1.2.1.6.1');

        if ($new_description) {
            $new_description =~ s/^"//;
            $new_description =~ s/"$//;
            $description = "Wyse " . $new_description;
        }
    }

    return $description;
}

1;
