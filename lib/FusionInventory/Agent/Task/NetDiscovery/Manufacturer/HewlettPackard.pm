package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::HewlettPackard;

use strict;
use warnings;

sub getBetterDescription {
    my ($description, $snmp) = @_;

    return unless 
        $description =~ m/HP ETHERNET MULTI-ENVIRONMENT/ or
        $description =~ m/A SNMP proxy agent, EEPROM/;

    my $result = $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1');
    return $result if $result;

    $result = $snmp->get('.1.3.6.1.4.1.11.2.3.9.1.1.7.0');
    return unless $result;

    my @infos = split(/;/, $result);
    foreach my $info (@infos) {
        if ($_ =~ /^MDL:/) {
            $_ =~ s/MDL://;
            return $_;
        } elsif ($_ =~ /^MODEL:/) {
            $_ =~ s/MODEL://;
            return $_;
        }
    }

    return;
}

1;
