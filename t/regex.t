#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Regexp;

my @network_ok_tests = qw(
    10.0.0.0/32
    10.0.0/24
    10.0/16
    10/8
);

my @network_nok_tests = qw(
    10.0.0.0
);

plan tests =>
    (scalar @network_ok_tests) +
    (scalar @network_nok_tests);

foreach my $test (@network_ok_tests) {
    ok($test =~ $network_pattern, "$test matches network pattern");
}

foreach my $test (@network_nok_tests) {
    ok($test !~ $network_pattern, "$test doesn't match network pattern");
}
