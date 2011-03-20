#!/usr/bin/perl -w

use FusionInventory::Agent::Task::NetDiscovery;

use Test::More;

use strict;
use warnings;

my @tests = (
        {
        s => '
        Nmap version 5.50 ( http://nmap.org )',
        v => '5.50',
        needOldArg => '',
        },
        {
        s => '
        Nmap version 5.51 ( http://nmap.org )',
        v => '5.51',
        needOldArg => '',
        },
        {
        s => '
        Nmap version 5.21 ( http://nmap.org )',
        v => '5.21',
        needOldArg => 1,
        },
        {
        s => '
        Nmap version 5.49 ( http://nmap.org )',
        v => '5.49',
       needOldArg => '',
        },
        );

plan tests => 2 * int @tests;

foreach my $test (@tests) {
    my $results = FusionInventory::Agent::Task::NetDiscovery::parseNmapVersion($test->{s});
    is_deeply($results, $test->{v});

    my $needOldArg = FusionInventory::Agent::Task::NetDiscovery::compareNmapVersion(5.29, $test->{v});
    is_deeply($needOldArg, $test->{needOldArg});
}
