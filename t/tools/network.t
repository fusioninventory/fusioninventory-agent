#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Network;

my @hex2quad_tests = (
    [ 'ffffffff', '255.255.255.255' ],
    [ '7f7f7f7f', '127.127.127.127' ]
);

my @mask_tests = (
    [ '127.0.0.1',   32, '255.255.255.255' ],
    [ '191.168.0.1', 24, '255.255.255.0'   ],
);

my @mac_tests = (
    [ '0xAABBCCDDEEFF', 'AA:BB:CC:DD:EE:FF' ],
    [ 'AABBCCDDEEFF',   'AA:BB:CC:DD:EE:FF' ],
);

plan tests =>
    scalar @hex2quad_tests +
    scalar @mask_tests +
    scalar @mac_tests;

foreach my $test (@hex2quad_tests) {
    is(
        hex2quad($test->[0]),
        $test->[1],
        "$test->[0] conversion"
    );
}

foreach my $test (@mac_tests) {
    is(
        getCanonicalMacAddress($test->[0]),
        $test->[1],
        "$test->[0] canonicalisation"
    );
}

foreach my $test (@mask_tests) {
    is(
        getNetworkMask($test->[0], $test->[1]),
        $test->[2],
        "$test->[0]/$test->[1] mask extraction"
    );
}
