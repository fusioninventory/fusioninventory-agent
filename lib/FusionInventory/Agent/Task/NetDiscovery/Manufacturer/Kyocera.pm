package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Kyocera;

use strict;
use warnings;

sub getBetterDescription {
    my ($description, $snmp) = @_;

    if ($description =~ m/,HP,JETDIRECT,J/) {
        return $snmp->get('.1.3.6.1.4.1.1229.2.2.2.1.15.1');
    }

    if (
        $description eq "KYOCERA MITA Printing System" or
        $description eq "KYOCERA Printer I/F"          or 
        $description eq "SB-110"
    ) {
        my $result = $snmp->get('.1.3.6.1.4.1.1347.42.5.1.1.2.1');
        return $result if $result;

        $result = $snmp->get('.1.3.6.1.4.1.1347.43.5.1.1.1.1');
        return $result if $result;

        $result = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
        return unless $result;

        my @infos = split(/;/, $result);
        foreach (@infos) {
            if ($_ =~ /^MDL:/) {
                $_ =~ s/MDL://;
                return $_;
            } elsif ($_ =~ /^MODEL:/) {
                $_ =~ s/MODEL://;
                return $_;
            }
        }
    }

    return;
}

1;
