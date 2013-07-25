#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::MacOS::CPU;

my %tests = (
    '10.6-macmini' => [
        {
            CORE         => '2',
            MANUFACTURER => 'Intel',
            NAME         => 'Intel Core 2 Duo',
            THREAD       => 2,
            FAMILYNUMBER => '6',
            MODEL        => '23',
            STEPPING     => '10',
            SPEED        => '2260'
        },
    ]
    );

plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'fatal' ],
    debug    => 1
);
my $inventory = FusionInventory::Agent::Inventory->new(logger => $logger);

foreach my $test (keys %tests) {
    my $sysctl = "resources/macos/sysctl/$test";
    my $file = "resources/macos/system_profiler/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::MacOS::CPU::_getCpus(file => $file,sysctl => $sysctl);
    cmp_deeply(\@cpus, $tests{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } "$test: registering";
}
