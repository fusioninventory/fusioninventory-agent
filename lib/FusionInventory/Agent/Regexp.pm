package FusionInventory::Agent::Regexp;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $mac_address_pattern
    $ip_address_pattern
    $hex_mac_address_pattern
    $hex_ip_address_pattern
);

my $hex_byte = qr/[0-9A-F]{2}/i;
my $dec_byte = qr/[0-9]{1,3}/;

our $mac_address_pattern = qr/
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte
/x;

our $ip_address_pattern = qr/
    $dec_byte \. $dec_byte \. $dec_byte \. $dec_byte
/x;

our $hex_mac_address_pattern = qr/
    $hex_byte $hex_byte $hex_byte $hex_byte $hex_byte $hex_byte
/x;

our $hex_ip_address_pattern = qr/
    $hex_byte $hex_byte $hex_byte $hex_byte
/x;

1;

__END__

=head1 NAME

FusionInventory::Agent::Regexp - Generic regular expressions

=head1 DESCRIPTION

This module provides some generic regular expressions.

=head1 PATTERNS

=head2 mac_address_pattern

This pattern matches a MAC address.

=head2 ip_address_pattern

This pattern matches an IP address.

=head2 hax_mac_address_pattern

This pattern matches a MAC address in hexadecimal form.

=head2 hax_ip_address_pattern

This pattern matches an IP address in hexadecimal form.
