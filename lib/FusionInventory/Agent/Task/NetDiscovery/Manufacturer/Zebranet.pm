package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Zebranet;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if($description =~ m/ZebraNet PrintServer/) {
        my $description_new = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
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
