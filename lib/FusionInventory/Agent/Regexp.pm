package FusionInventory::Agent::Regexp;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $mac_address_pattern
    $ip_address_pattern
);

my $hex_byte = qr/[0-9A-F]{2}/i;
my $dec_byte = qr/[0-9]{1,3}/;

our $mac_address_pattern = qr/
    $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte : $hex_byte
/x;

our $ip_address_pattern = qr/
    $dec_byte \. $dec_byte \. $dec_byte \. $dec_byte
/x;

1;
