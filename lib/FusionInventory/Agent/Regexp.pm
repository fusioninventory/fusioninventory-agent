package FusionInventory::Agent::Regexp;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $macaddress_pattern
);

our $byte = qr/[0-9A-F]{2}/i;
our $macaddress_pattern = qr/$byte : $byte : $byte : $byte : $byte : $byte/x;

1;
