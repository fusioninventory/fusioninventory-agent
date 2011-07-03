package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Axis;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/AXIS OfficeBasic Network Print Server/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.2699.1.2.1.2.1.1.3.1');
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

    return $description;
}

1;
