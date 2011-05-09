#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Modems;

my %tests = (
    'aix-5.3' => [],
    'aix-6.1' => [],
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test-adapter";
    my @modems = FusionInventory::Agent::Task::Inventory::OS::AIX::Modems::_getModems(file => $file);
    is_deeply(\@modems, $tests{$test}, "modems: $test");
}
