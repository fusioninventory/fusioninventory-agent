package FusionInventory::Agent::SNMP;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);

our $VERSION = '1.1';

1;
__END__

=head1 NAME

FusionInventory::Agent::SNMP - Base class for SNMP client

=head1 DESCRIPTION

This is the object used by the agent to perform SNMP queries.

=head1 METHODS

=head2 get($oid)

This method returns a single value, corresponding to a single OID. The value is
normalised to remove any control character, and hexadecimal mac addresses are
translated into plain ascii.

=head2 walk($oid)

This method returns an hashref of values, indexed by their OIDs, starting from
the given one. The values are normalised to remove any control character, and
hexadecimal mac addresses are translated into plain ascii.
