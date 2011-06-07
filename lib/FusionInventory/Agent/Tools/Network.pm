package FusionInventory::Agent::Tools::Network;

use strict;
use warnings;
use base 'Exporter';

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getSubnetAddress
    getSubnetAddressIPv6
    getNetworkMask
    hex2quad
);

sub getSubnetAddress {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    # load Net::IP conditionnaly
    return unless can_load("Net::IP");
    Net::IP->import(':PROC');

    my $binaddress = ip_iptobin($address, 4);
    my $binmask    = ip_iptobin($mask, 4);
    my $binsubnet  = $binaddress & $binmask;

    return ip_bintoip($binsubnet, 4);
}

sub getSubnetAddressIPv6 {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    # load Net::IP conditionnaly
    return unless can_load("Net::IP");
    Net::IP->import(':PROC');

    my $binaddress = ip_iptobin($address, 6);
    my $binmask    = ip_iptobin($mask, 6);
    my $binsubnet  = $binaddress & $binmask;

    return ip_bintoip($binsubnet, 6);
}

sub hex2quad {
    my ($address) = @_;

    my @bytes = $address =~ /(..)(..)(..)(..)/;
    return join('.', map { hex($_) } @bytes);
}

sub getNetworkMask {
    my ($address, $prefix) = @_;

    my $mask;
    $mask .= 1 foreach(1..$prefix);
    $mask .= 0 foreach(1..(32-$prefix));

    if ($mask =~ /^(\d{8})(\d{8})(\d{8})(\d{8})$/) {
         $mask = oct("0b".$1).".".oct("0b".$2).".".oct("0b".$3).".".oct("0b".$4);
    }
    return $mask;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Network - Network-related functions

=head1 DESCRIPTION

This module provides some network-related functions.

=head1 FUNCTIONS

=head2 hex2quad($address)

Convert an ip address from hexadecimal to quad form.

=head2 getSubnetAddress($address, $mask)

Returns the subnet address for IPv4.

=head2 getSubnetAddressIPv6($address, $mask)

Returns the subnet address for IPv6.

=head2 getNetworkMask($address, $prefix)

Returns the network mask.
