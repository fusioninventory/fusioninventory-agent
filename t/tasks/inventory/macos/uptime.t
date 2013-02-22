#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::MacOS::Uptime;

my %tests = (
        '1325070226' => '1325070226',
        'sec = 1325070226' => '1325070226'
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
 my $r = FusionInventory::Agent::Task::Inventory::MacOS::Uptime::_getBootTime(string => $test);
    ok($r eq $tests{$test});
}
