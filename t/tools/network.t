#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Network;

my @hex2quad_tests = (
    [ 'ffffffff', '255.255.255.255' ],
    [ '7f7f7f7f', '127.127.127.127' ]
);

plan tests => scalar @hex2quad_tests;

foreach my $test (@hex2quad_tests) {
    is(
        hex2quad($test->[0]),
        $test->[1],
        "$test->[0] conversion"
    );
}
