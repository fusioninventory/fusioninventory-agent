#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Generic::PCI::Sounds;

my %tests = (
    'dell-xt2' => [
        {
            NAME => 'Audio device',
            DESCRIPTION => 'rev 03',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) HD Audio Controller'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @sounds = FusionInventory::Agent::Task::Inventory::Generic::PCI::Sounds::_getSounds(file => $file);
    cmp_deeply(\@sounds, $tests{$test}, $test);
}
