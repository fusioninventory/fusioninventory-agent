package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Kyocera;

use strict;
use warnings;

sub getDescriptionHP {
    my ($snmp) = @_;

    return $snmp->get('.1.3.6.1.4.1.1229.2.2.2.1.15.1');
}

sub getDescriptionOther {
    my ($snmp) = @_;

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

1;
