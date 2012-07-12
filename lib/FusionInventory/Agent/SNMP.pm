package FusionInventory::Agent::SNMP;

use strict;
use warnings;
use base 'Exporter';

use Encode qw(encode);
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

our $VERSION = '1.1';

our @EXPORT_OK = qw(
    getSanitizedSerialNumber
    getSanitizedMacAddress
    getElement
    getElements
    getLastElement
    getNextToLastElement
);


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

sub getSanitizedMacAddress {
    my ($value) = @_;

    if ($value !~ /^0x/) {
        # convert from binary to hexadecimal
        $value = unpack 'H*', $value;
    } else {
        # drop hex prefix
        $value =~ s/^0x//;
    }

    return $value;
}

sub getSanitizedSerialNumber {
    my ($value) = @_;

    $value =~ s/\n//g;
    $value =~ s/\r//g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/\.{2,}//g;

    return $value;
}

sub getElement {
    my ($oid, $index) = @_;

    my @array = split(/\./, $oid);
    return $array[$index];
}

sub getLastElement {
    my ($oid) = @_;

    return getElement($oid, -1);
}

sub getNextToLastElement {
    my ($oid) = @_;

    return getElement($oid, -2);
}

sub getElements {
    my ($oid, $first, $last) = @_;

    my @array = split(/\./, $oid);
    return @array[$first .. $last];
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

=head1 FUNCTIONS

=head2 getSanitizedSerialNumber($value)

Return a sanitized serial number.

=head2 getSanitizedMacAddress($value)

Return a sanitized mac address.

=head2 getElement($oid, $index)

return the $index element of an oid.

=head2 getLastElement($oid)

return the last element of an oid.

=head2 getNextToLastElement($oid)

return the next to last element of an oid.

=head2 getElements($oid, $first, $last)

return all elements of index in range $first to $last of an oid.
