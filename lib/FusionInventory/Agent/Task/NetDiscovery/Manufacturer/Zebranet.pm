package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Zebranet;

use strict;
use warnings;

sub discovery {
    my ($empty, $description, $snmp) = @_;

    return unless $description =~ m/ZebraNet PrintServer/;
    my $result = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
    if ($result) {
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
