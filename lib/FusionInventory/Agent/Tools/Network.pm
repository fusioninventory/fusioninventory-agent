package FusionInventory::Agent::Tools::Network;

use strict;
use warnings;
use base 'Exporter';

use Net::IP qw(:PROC);

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    $mac_address_pattern
    $ip_address_pattern
    $alt_mac_address_pattern
    $hex_ip_address_pattern
    $network_pattern
    getSubnetAddress
    getSubnetAddressIPv6
    getNetworkMask
    hex2canonical
    alt2canonical
);

my $hex_byte = qr/[0-9A-F]{2}/i;
my $dec_byte = qr/[0-9]{1,3}/;

our $mac_address_pattern = qr/
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte
/x;

our $ip_address_pattern = qr/
    $dec_byte \. $dec_byte \. $dec_byte \. $dec_byte
/x;

our $alt_mac_address_pattern = qr/
    $hex_byte $hex_byte $hex_byte $hex_byte $hex_byte $hex_byte
/x;

our $hex_ip_address_pattern = qr/
    $hex_byte $hex_byte $hex_byte $hex_byte
/x;

our $network_pattern = qr/
    $dec_byte (?:\. $dec_byte (?:\. $dec_byte (?:\. $dec_byte)?)?)? \/ \d{1,2}
/x;

sub getSubnetAddress {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    my $binaddress = ip_iptobin($address, 4);
    my $binmask    = ip_iptobin($mask, 4);
    my $binsubnet  = $binaddress & $binmask; ## no critic (ProhibitBitwise)

    return ip_bintoip($binsubnet, 4);
}

sub getSubnetAddressIPv6 {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    my $binaddress = ip_iptobin($address, 6);
    my $binmask    = ip_iptobin($mask, 6);

    return unless $binaddress && $binmask;

    my $binsubnet  = $binaddress & $binmask; ## no critic (ProhibitBitwise)

    return ip_bintoip($binsubnet, 6);
}

sub hex2canonical {
    my ($address) = @_;

    my @bytes = $address =~ /^(?:0x)?(..)(..)(..)(..)$/;
    return join('.', map { hex($_) } @bytes);
}

sub alt2canonical {
    my ($address) = @_;

    my @bytes = $address =~ /^(..)(..)(..)(..)(..)(..)$/;
    return join(':', @bytes);
}

sub getNetworkMask {
    my ($address, $prefix) = @_;

    my $mask;
    $mask .= 1 foreach(1..$prefix);
    $mask .= 0 foreach(1..(32-$prefix));

    my @bytes = $mask =~ /^(\d{8})(\d{8})(\d{8})(\d{8})$/;
    return join ('.', map { oct('0b' . $_) } @bytes);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Network - Network-related patterns and functions

=head1 DESCRIPTION

This module provides some network-related patterns and functions.

=head1 PATTERNS

=head2 mac_address_pattern

This pattern matches a MAC address in canonical form (aa:bb:cc:dd:ee:ff).

=head2 ip_address_pattern

This pattern matches an IP address in canonical form (xyz.xyz.xyz.xyz).

=head2 alt_mac_address_pattern

This pattern matches a MAC address in alternative form (aabbccddeeff).

=head2 hex_ip_address_pattern

This pattern matches an IP address in hexadecimal form (aabbccdd).

=head1 FUNCTIONS

=head2 hex2canonical($address)

Convert an ip address from hexadecimal to canonical form.

=head2 alt2canonical($address)

Convert a mac address from alternative to canonical form.

=head2 getSubnetAddress($address, $mask)

Returns the subnet address for IPv4.

=head2 getSubnetAddressIPv6($address, $mask)

Returns the subnet address for IPv6.

=head2 getNetworkMask($address, $prefix)

Returns the network mask.
