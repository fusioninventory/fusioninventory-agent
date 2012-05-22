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
    my $sysctl = "resources/macos/sysctl/$test";
    my $file = "resources/macos/system_profiler/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::MacOS::CPU::_getCpus(file => $file,sysctl => $sysctl);
    is_deeply(\@cpus, $tests{$test}, $test);
}
