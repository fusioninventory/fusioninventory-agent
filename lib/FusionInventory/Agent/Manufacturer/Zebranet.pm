package FusionInventory::Agent::Manufacturer::Zebranet;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.4.1.10642.1.1.0');
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
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::Zebranet - Zebranet-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Zebranet hardware.

=head1 FUNCTIONS

=head2 getDescription()

Get a better description for some specific devices than the one retrieved
directly through SNMP.
