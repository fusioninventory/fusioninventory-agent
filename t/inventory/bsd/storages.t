#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::BSD::Storages;

my %tests = (
    'freebsd-1' => [
        {
            'DESCRIPTION' => 'da0s1b'
        },
        {
            'DESCRIPTION' => 'da0s1a'
        },
        {
            'DESCRIPTION' => 'da0s1d'
        },
        {
            'DESCRIPTION' => 'acd0'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/bsd/fstab/$test";
    my @results = FusionInventory::Agent::Task::Inventory::Input::BSD::Storages::_getDevicesFromFstab(file => $file);
    is_deeply(\@results, $tests{$test}, $test);
}
