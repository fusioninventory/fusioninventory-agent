#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU;

my @tests = (
    [
        '4 X UltraSPARC-III 750MHz',
        4,
        {
            NAME   => 'UltraSPARC-III',
            SPEED  => 750,
            THREAD => 0,
            CORE   => 1
        }
    ],
    [
        '2 X dual-thread UltraSPARC-IV 1350MHz',
        2,
        {
            NAME   => 'UltraSPARC-IV (dual-thread)',
            SPEED  => 1350,
            THREAD => 'dual-thread',
            CORE   => 2
        }
    ],
    [
        'UltraSPARC-IIIi 1002MHz',
        1,
        {
            NAME   => 'UltraSPARC-IIIi',
            SPEED  => 1002,
            THREAD => 0,
            CORE   => 1
        }
    ],
    [ 
        '8-core quad-thread UltraSPARC-T1 1000MHz',
        8,
        {
            NAME   => 'UltraSPARC-T1 (8-core quad-thread)',
            SPEED  => 1000,
            THREAD => 'quad-thread',
            CORE   => 1
        }
    ],
    [ 
        '4-core quad-thread UltraSPARC-T1 1000MHz',
        4,
        {
            NAME   => 'UltraSPARC-T1 (4-core quad-thread)',
            SPEED  => 1000,
            THREAD => 'quad-thread',
            CORE   => 1
        }
    ],
    [ 
        '8-core 8-thread UltraSPARC-T2 1165MHz',
        8,
        {
            NAME   => 'UltraSPARC-T2 (8-core 8-thread)',
            SPEED  => 1165,
            THREAD => '8-thread',
            CORE   => 1
        }
    ],
    [ 
        '4-core 8-thread UltraSPARC-T2 1165MHz',
        4,
        {
            NAME   => 'UltraSPARC-T2 (4-core 8-thread)',
            SPEED  => 1165,
            THREAD => '8-thread',
            CORE   => 1
        }
    ],
    [ 
        '6 X dual-core dual-thread SPARC64-VI 2150MHz',
        6,
        {
            NAME   => 'SPARC64-VI (dual-core dual-thread)',
            SPEED  => 2150,
            THREAD => 'dual-thread',
            CORE   => '6 dual-core',
        }
    ],
    [ 
        '4 X dual-core dual-thread SPARC64-VI 2150MHz',
        4,
        {
            NAME   => 'SPARC64-VI (dual-core dual-thread)',
            SPEED  => 2150,
            THREAD => 'dual-thread',
            CORE   => '4 dual-core',
        }
    ],
);

plan tests => scalar @tests * 2;

foreach my $test (@tests) {
    my ($count, $cpu) = FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU::_parseSpec($test->[0]);
    is($count, $test->[1], $test->[0]);
    is_deeply($cpu, $test->[2], $test->[0]);
}
