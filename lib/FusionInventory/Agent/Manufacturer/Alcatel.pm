package FusionInventory::Agent::Manufacturer::Alcatel;

use strict;
use warnings;

sub getDescription {
    my ($snmp) = @_;

    my $result = $snmp->get('.1.3.6.1.2.1.47.1.1.1.1.13.1');
    return $result eq "OS66-P24" ? "OmniStack 6600-P24" : $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Manufacturer::Alcatel - Alcatel-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Alcatel hardware.

=head1 FUNCTIONS

=head2 getDescription()

Get a better description for some specific devices than the one retrieved
directly through SNMP.
