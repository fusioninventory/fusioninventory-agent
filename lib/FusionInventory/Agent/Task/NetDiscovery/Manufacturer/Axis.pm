package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Axis;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/AXIS OfficeBasic Network Print Server/) {
        my $description_new = $snmp->get('.1.3.6.1.4.1.2699.1.2.1.2.1.1.3.1');
        if ($description_new ne "null") {
            my @infos = split(/;/,$description_new);
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
