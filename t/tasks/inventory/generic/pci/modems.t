#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Generic::PCI::Modems;

my %tests = (
    'dell-xt2' => []
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @modems = FusionInventory::Agent::Task::Inventory::Generic::PCI::Modems::_getModems(file => $file);
    cmp_deeply(\@modems, $tests{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'MODEMS', entry => $_)
            foreach @modems;
    } "$test: registering";
}
