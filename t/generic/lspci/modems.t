#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'latitude-xt2' => undef,
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/lspci/$test";
    my $modems = FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems::_getModemControllers($logger, $file);
    is_deeply($modems, $tests{$test}, $test);
}
