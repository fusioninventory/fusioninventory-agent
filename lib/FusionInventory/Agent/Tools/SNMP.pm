package FusionInventory::Agent::Tools::SNMP;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    getElement
    getElements
    getLastElement
);

sub getElement {
    my ($oid, $index) = @_;

    my @array = split(/\./, $oid);
    return $array[$index];
}

sub getLastElement {
    my ($oid) = @_;

    return getElement($oid, -1);
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

=head2 getElement($oid, $index)

return the $index element of an oid.

=head2 getLastElement($oid)

return the last element of an oid.

=head2 getElements($oid, $first, $last)

return all elements of index in range $first to $last of an oid.
