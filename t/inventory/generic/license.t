#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Generic::License;

my %adobe_tests = (
    'sample1' => [
    ]
);

plan tests => scalar keys %adobe_tests;

foreach my $test (keys %adobe_tests) {
    my $file = "resources/generic/license/adobe/cache.db-$test";
    my @licenses = FusionInventory::Agent::Tools::Generic::License::getAdobeLicenses(file => $file);
    is_deeply(\@licenses, $adobe_tests{$test}, $test);
}

1;
