#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Config::File;

my %config = (
    sample1 => {
        'no-module'   => ['snmpquery', 'wakeonlan'],
        'no-category' => [],
        'httpd-trust' => []
    },
    sample2 => {
        'no-module'   => [],
        'no-category' => ['printer'],
        'httpd-trust' => ['example', '127.0.0.1', 'foobar', '123.0.0.0/10']
    },
    sample3 => {
        'no-module'   => [],
        'no-category' => [],
        'httpd-trust' => []
    }

);

plan tests => (scalar keys %config) * 3;

foreach my $test (keys %config) {
    my $c = FusionInventory::Agent::Config::File->new(
        file => "resources/config/$test"
    );

    foreach my $k (qw/ no-module no-category httpd-trust /) {
        cmp_deeply($c->{$k}, $config{$test}->{$k}, $test." ".$k);
    }
}
