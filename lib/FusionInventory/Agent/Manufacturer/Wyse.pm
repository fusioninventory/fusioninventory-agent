package FusionInventory::Agent::Manufacturer::Wyse;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.4.1.714.1.2.5.6.1.2.1.6.1');
    return unless $result;

    $result =~ s/^"//;
    $result =~ s/"$//;
    $result = "Wyse $result";
    return $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::Wyse - Wyse-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Wyse hardware.

=head1 FUNCTIONS

=head2 getDescription()

Get a better description for some specific devices than the one retrieved
directly through SNMP.
