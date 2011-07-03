package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::HewlettPackard;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if (
        $description =~ m/HP ETHERNET MULTI-ENVIRONMENT/ or
        $description =~ m/A SNMP proxy agent, EEPROM/
    ) {

        my $new_description = $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');

        if (!$new_description) {
            $new_description = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
            if ($new_description) {
                my @infos = split(/;/, $new_description);
                foreach (@infos) {
                    if ($_ =~ /^MDL:/) {
                        $_ =~ s/MDL://;
                        $description = $_;
                        last;
                    } elsif ($_ =~ /^MODEL:/) {
                        $_ =~ s/MODEL://;
                        $description = $_;
                        last;
                    }
                }
            }
        }
    }

    return $description;
}

1;
