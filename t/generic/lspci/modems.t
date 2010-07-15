#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;
use Test::More;

my %tests = (
    'latitude-xt2' => undef,
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/lspci/$test";
    my $modems = FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems::parseLspci($file, '<');
    is_deeply($modems, $tests{$test}, $test);
}
