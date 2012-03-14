package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::HewlettPackard;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
    return $result if $result;

    $result = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
    return unless $result;

    my @infos = split(/;/, $result);
    foreach my $info (@infos) {
        if ($info =~ /^MDL:/) {
            $info =~ s/MDL://;
            return $info;
        } elsif ($info =~ /^MODEL:/) {
            $info =~ s/MODEL://;
            return $info;
        }
    }
}

1;
