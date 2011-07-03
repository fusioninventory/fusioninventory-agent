package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Kyocera;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    if ($description =~ m/,HP,JETDIRECT,J/) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.1229.2.2.2.1.15.1');
        $description = $new_description if $new_description;
    }

    if (
        $description eq "KYOCERA MITA Printing System" or
        $description eq "KYOCERA Printer I/F"          or 
        $description eq "SB-110"
    ) {
        my $new_description = $snmp->get('.1.3.6.1.4.1.1347.42.5.1.1.2.1');
        if ($new_description) {
            $description = $new_description;
        } else {
            $new_description = $snmp->get('.1.3.6.1.4.1.1347.43.5.1.1.1.1');
            if ($new_description) {
                $description = $new_description;
            } else {
                $new_description = $snmp->get('.1.3.6.1.4.1.1347.43.5.1.1.1.1');
                if ($new_description) {
                    $description = $new_description;
                } else {
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
        }
    }

    return $description;
}

1;
