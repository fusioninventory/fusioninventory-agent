package FusionInventory::Agent::Tools::Network;

use strict;
use warnings;
use base 'Exporter';

use UNIVERSAL::require;
use Net::IP qw(:PROC);

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    $mac_address_pattern
    $ib_mac_address_pattern
    $any_mac_address_pattern
    $ip_address_pattern
    $alt_mac_address_pattern
    $hex_ip_address_pattern
    $network_pattern
    getSubnetAddress
    getSubnetAddressIPv6
    getNetworkMask
    getNetworkMaskIPv6
    hex2canonical
    alt2canonical
    resolve
    compile
    isPartOf
);

my $dec_byte        = qr/[0-9]{1,3}/;
my $hex_byte        = qr/[0-9A-F]{1,2}/i;
my $padded_hex_byte = qr/[0-9A-F]{2}/i;

our $mac_address_pattern = qr/
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte
/x;

our $ib_mac_address_pattern = qr/
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte :
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte :
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte :
    $hex_byte : $hex_byte
/x;

our $any_mac_address_pattern = qr/
    (?:$ib_mac_address_pattern|$mac_address_pattern)
/x;

our $ip_address_pattern = qr/
    $dec_byte \. $dec_byte \. $dec_byte \. $dec_byte
/x;

our $alt_mac_address_pattern = qr/
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
/x;

our $hex_ip_address_pattern = qr/
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
    $padded_hex_byte
/x;

our $network_pattern = qr/
    $dec_byte (?:\. $dec_byte (?:\. $dec_byte (?:\. $dec_byte)?)?)? \/ \d{1,2}
/x;

sub getSubnetAddress {
    my ($address, $mask) = @_;

    return undef unless $address && $mask; ## no critic (ExplicitReturnUndef)

    my $binaddress = ip_iptobin($address, 4);
    my $binmask    = ip_iptobin($mask, 4);
    my $binsubnet  = $binaddress & $binmask; ## no critic (ProhibitBitwise)

    return ip_bintoip($binsubnet, 4);
}

sub getSubnetAddressIPv6 {
    my ($address, $mask) = @_;

    return undef unless $address && $mask; ## no critic (ExplicitReturnUndef)

    my $binaddress = ip_iptobin(ip_expand_address($address, 6), 6);
    my $binmask    = ip_iptobin(ip_expand_address($mask, 6), 6);
    my $binsubnet  = $binaddress & $binmask; ## no critic (ProhibitBitwise)

    return ip_compress_address(ip_bintoip($binsubnet, 6), 6);
}

sub hex2canonical {
    my ($address) = @_;
    return unless $address;

    my @bytes = $address =~ /^(?:0x)?(..)(..)(..)(..)$/;
    return join('.', map { hex($_) } @bytes);
}

sub alt2canonical {
    my ($address) = @_;
    return unless $address;

    my @bytes = $address =~ /^(?:0x)?(..)(..)(..)(..)(..)(..)$/;
    return join(':', @bytes);
}

sub getNetworkMask {
    my ($prefix) = @_;

    return undef unless $prefix; ## no critic (ExplicitReturnUndef)

    return ip_bintoip(ip_get_mask($prefix, 4), 4);
}

sub getNetworkMaskIPv6 {
    my ($prefix) = @_;

    return undef unless $prefix; ## no critic (ExplicitReturnUndef)

    return ip_compress_address(ip_bintoip(ip_get_mask($prefix, 6), 6), 6);
}

sub resolve {
    my ($string, $logger) = @_;

    my @ret;

    Socket::GetAddrInfo->require();
    Socket->require();

    my ($error, @results) = Socket::GetAddrInfo::getaddrinfo(
        $string, "", { socktype => Socket::SOCK_RAW() }
    );
    if ($error) {
        $logger->error(
            "unable to get address for '$string': $error"
        ) if $logger;
        return;
    }

    # and push all of their addresses in the list
    foreach my $result (@results) {
        my ($error, $host) = Socket::GetAddrInfo::getnameinfo(
            $result->{addr},
            Socket::GetAddrInfo::NI_NUMERICHOST(),
        );
        if ($error) {
            $logger->error(
                "unable to translate binary address for '$string': $error"
            ) if $logger;
            next;
        }

        # Drop the zone index, as Net::IP does not support it
        $host =~ s/%.*$//;

        push @ret, Net::IP->new($host);
    }

    return @ret;
}

sub compile {
    my ($string, $logger) = @_;

    return unless $string;

    # that's already an IP address, just convert it
    return Net::IP->new($string)
        if $string =~ /^$ip_address_pattern/;

    # otherwise resolve the name
    return resolve($string, $logger);
}

sub isPartOf {
    my ($string, $ranges, $logger) = @_;

    return unless $string;
    return unless $ranges;

    my $address = Net::IP->new($string);

    if (!$address) {
        $logger->error("Not well formatted source IP: $string");
        return;
    }

    foreach my $range (@{$ranges}) {
        my $result = $address->overlaps($range);

        if (!$result && Net::IP::Error()) {
            $logger->debug("Server: ".Net::IP::Error());
            next;
        }

        # included in trusted range
        return 1 if $result == $IP_A_IN_B_OVERLAP;

        # equals trusted address
        return 1 if $result == $IP_IDENTICAL;
    }

    return 0;
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

=head2 getNetworkMask($prefix)

Returns the network mask for IPv4.

=head2 getNetworkMaskIPv6($prefix)

Returns the network mask for IPv6.

=head2 resolve($host, $logger)

Returns a list of addresses, as Net::IP objects, for the given host name, as a
string.

=head2 compile($spec, $logger)

Returns a list of addresses, as Net::IP objects, for the given IP address or
host name, as a string.

=head2 isPartOf($address, $addresses, $logger)

Returns true if the given address, as a string, is part of any address from the
given list, as Net::IP objects.
