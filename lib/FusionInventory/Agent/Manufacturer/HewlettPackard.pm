package FusionInventory::Agent::Manufacturer::HewlettPackard;

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
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::Hewlett-Packard - Hewlett-Packard-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Hewlett-Packard hardware.

=head1 FUNCTIONS

=head2 getDescription()

Get a better description for some specific devices than the one retrieved
directly through SNMP.
