package FusionInventory::Agent::SNMP;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

our $VERSION = '1.1';

my @bad_oids = qw(
    .1.3.6.1.2.1.2.2.1.6
    .1.3.6.1.2.1.4.22.1.2
    .1.3.6.1.2.1.17.1.1.0
    .1.3.6.1.2.1.17.4.3.1.1
    .1.3.6.1.4.1.9.9.23.1.2.1.1.4
);
my $bad_oids_pattern = '^(' . join('|', map { quotemeta($_) } @bad_oids) . ')';

sub getMacAddress {
    my ($self, $oid) = @_;

    my $value = $self->get($oid);
    return unless $value;

    if ($oid =~ /$bad_oids_pattern/) {
        $value = getSanitizedMacAddress($value);
    }

    $value = alt2canonical($value);

    return $value;
}

sub walkMacAddresses {
    my ($self, $oid) = @_;

    my $values = $self->walk($oid);
    return unless $values;

    if ($oid =~ /$bad_oids_pattern/) {
        foreach my $value (values %$values) {
            $value = getSanitizedMacAddress($value);
        }
    }

    foreach my $value (values %$values) {
        $value = alt2canonical($value);
    }

    return $values;
}

sub getSerialNumber {
    my ($self, $oid) = @_;

    my $value = $self->get($oid);
    return unless $value;

    return getSanitizedSerialNumber($value);
}

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

=head2 getSerialNumber($oid)

Wraps get($oid), assuming the value is a serial number and sanitizing it
accordingly.

=head2 getMacAddress($oid)

Wraps get($oid), assuming the value is a mac address and sanitizing it
accordingly.

=head2 walkMacAddresses($oid)

Wraps walk($oid), assuming the values are mac addresses and sanitizing them
accordingly.
