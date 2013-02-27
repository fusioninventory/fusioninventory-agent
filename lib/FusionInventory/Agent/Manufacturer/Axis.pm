package FusionInventory::Agent::Manufacturer::Axis;

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
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::Axis - Axis-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Axis hardware.

=head1 FUNCTIONS

=head2 getDescription()

Get a better description for some specific devices than the one retrieved
directly through SNMP.
