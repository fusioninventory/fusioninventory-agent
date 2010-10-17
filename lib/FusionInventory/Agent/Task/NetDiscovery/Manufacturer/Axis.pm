package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Axis;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.4.1.2699.1.2.1.2.1.1.3.1');

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
