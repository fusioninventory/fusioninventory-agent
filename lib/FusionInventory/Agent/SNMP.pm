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

=head2 switch_vlan_context($vlan_id)

Switch to a new vlan-specific context.

With SNMPv1 and SNMPv2, this creates a new SNMP connection, using a community
derived from original one, with vlan ID appended as a suffix. With SNMPv3,
ensure all subsequent requests use relevant context.

=head2 reset_original_context()

Reset to original context.

=head2 get($oid)

This method returns a single value, corresponding to a single OID. The value is
normalised to remove any control character, and hexadecimal mac addresses are
translated into plain ascii.

=head2 walk($oid)

This method returns an hashref of values, indexed by their OIDs, starting from
the given one. The values are normalised to remove any control character, and
hexadecimal mac addresses are translated into plain ascii.
