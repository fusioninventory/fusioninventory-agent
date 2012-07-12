package FusionInventory::Agent::Tools::SNMP;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
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

FusionInventory::Agent::Tools::SNMP - SNMP-related functions

=head1 DESCRIPTION

This module provides some SNMP-related functions.

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
