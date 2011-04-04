#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

my %tests = (
    'dell-xt2' => []
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/lspci/$test";
    my @modems = FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems::_getModemControllers($logger, $file);
    is_deeply(\@modems, $tests{$test}, $test);
}
