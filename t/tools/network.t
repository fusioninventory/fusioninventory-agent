#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Network;

my @network_ok_tests = qw(
    10.0.0.0/32
    10.0.0/24
    10.0/16
    10/8
);

my @network_nok_tests = qw(
    10.0.0.0
);

my @hex2quad_tests = (
    [ 'ffffffff', '255.255.255.255' ],
    [ '7f7f7f7f', '127.127.127.127' ]
);

my @join2split_tests = (
    [ 'AABBCCDDEEFF', 'AA:BB:CC:DD:EE:FF' ],
);

my @mask_tests = (
    [ '127.0.0.1',   32, '255.255.255.255' ],
    [ '191.168.0.1', 24, '255.255.255.0'   ],
);

plan tests =>
    scalar @network_ok_tests  +
    scalar @network_nok_tests +
    scalar @hex2quad_tests    +
    scalar @join2split_tests  +
    scalar @mask_tests;

foreach my $test (@network_ok_tests) {
    ok($test =~ $network_pattern, "$test matches network pattern");
}

foreach my $test (@network_nok_tests) {
    ok($test !~ $network_pattern, "$test doesn't match network pattern");
}

foreach my $test (@hex2quad_tests) {
    is(
        hex2quad($test->[0]),
        $test->[1],
        "$test->[0] conversion"
    );
}

foreach my $test (@join2split_tests) {
    is(
        join2split($test->[0]),
        $test->[1],
        "$test->[0] conversion"
    );
}

foreach my $test (@mask_tests) {
    is(
        getNetworkMask($test->[0], $test->[1]),
        $test->[2],
        "$test->[0]/$test->[1] mask extraction"
    );
}
