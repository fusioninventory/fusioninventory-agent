#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::MacOS::CPU;

my %tests = (
    '10.6-macmini' => [
        {
            CORE         => '2',
            MANUFACTURER => 'Intel',
            NAME         => 'Intel Core 2 Duo',
            THREAD       => 1,
            FAMILYNUMBER => '6',
            MODEL        => '23',
            STEPPING     => '10',
            SPEED        => '2260'
        },
    ]
    );

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/macos/sysctl/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::MacOS::Memory::_getCpus(file => $file);
    is_deeply(\@cpus, $tests{$test}, $test);
}
