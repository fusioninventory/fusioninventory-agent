#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU;

my %memconf_tests = (
    sample4 => [
        2,
        {
            NAME         => 'Opteron(tm) Processor 270',
            MANUFACTURER => 'AMD',
            SPEED        => '1993',
            CORE         => '2'
        },
    ],
    sample3 => [
        1,
        {
            NAME         => 'SPARC-T3 (16-Core 8-Thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1649',
            CORE         => '16',
            THREAD       => '8'
        },
    ],
    sample2 => [
        1,
        {
            NAME         => 'UltraSPARC-IIi',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '270',
            CORE         => '1'
        },
    ],
    sample1 => [
        2,
        {
            NAME         => 'Xeon(R) E7320',
            MANUFACTURER => 'Intel',
            SPEED        => '2130',
            CORE         => '4'
        },
    ]
);

my %psrinfo_tests = (
    sample1 => [
        8,
        {
            NAME  => 'i386',
            SPEED => 2133
        }
    ]
);

my %spec_tests = (
    'Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)' => [
        1,
        {
            NAME         => 'UltraSPARC-T1 (8-core quad-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1000',
            THREAD       => '4',
            CORE         => '8'
        }
    ],
    'Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)' => [
        4,
        {
            NAME         => 'UltraSPARC-III',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '750',
            CORE         => '1'
        }
    ],
    'Sun Microsystems, Inc. SPARC Enterprise T5120 (8-core 8-thread UltraSPARC-T2 1165MHz)' => [
        1,
        {
            NAME         => 'UltraSPARC-T2 (8-core 8-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1165',
            THREAD       => '8',
            CORE         => '8'
        }
    ],
    'Sun Microsystems, Inc. Sun Fire V240 (UltraSPARC-IIIi 1002MHz)' => [
        1,
        {
            NAME         => 'UltraSPARC-IIIi',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1002',
            CORE         => '1'
        }
    ],
    'Sun Microsystems, Inc. Sun SPARC Enterprise M5000 Server (6 X dual-core dual-thread SPARC64-VI 2150MHz)' => [
        6,
        {
            NAME         => 'SPARC64-VI (dual-core dual-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '2150',
            THREAD       => '2',
            CORE         => '2'
        }
    ],
    'Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)' => [
        2,
        {
            NAME         => 'UltraSPARC-IV (dual-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1350',
            THREAD       => '2',
            CORE         => '2'
        }
    ],
    'Sun Microsystems, Inc. Sun Fire V20z (Solaris x86 machine) (2 X Dual Core AMD Opteron(tm) Processor 270 1993MHz)' => [
        '2',
        {
            NAME         => 'Opteron(tm) Processor 270',
            MANUFACTURER => 'AMD',
            SPEED        => '1993',
            CORE         => '2'
        }
    ],
    'Fujitsu SPARC Enterprise M4000 Server (4 X dual-core dual-thread SPARC64-VI 2150MHz)' => [
        '4',
        {
            NAME         => 'SPARC64-VI (dual-core dual-thread)',
            MANUFACTURER => 'Fujitsu',
            SPEED        => '2150',
            THREAD       => '2',
            CORE         => '2'
        }
    ],
    'Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (4-core quad-thread UltraSPARC-T1 1000MHz)'
      => [
        1,
        {
            NAME         => 'UltraSPARC-T1 (4-core quad-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1000',
            THREAD       => '4',
            CORE         => '4'
        }
    ],
    'Sun Microsystems, Inc. SPARC Enterprise T5120 (4-core 8-thread UltraSPARC-T2 1165MHz)' => [
        1,
        {
            NAME         => 'UltraSPARC-T2 (4-core 8-thread)',
            MANUFACTURER => 'Sun Microsystems',
            SPEED        => '1165',
            THREAD       => '8',
            CORE         => '4'
        }
    ]
);

plan tests => 
    (scalar keys %memconf_tests) +
    (scalar keys %psrinfo_tests) +
    (scalar keys %spec_tests)    ;

foreach my $test (keys %memconf_tests) {
    my $file    = "resources/solaris/memconf/$test";
    my @results = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_getCPUFromMemconf(file => $file);
    is_deeply(\@results, $memconf_tests{$test}, "memconf parsing: $test" );
}

foreach my $test (keys %psrinfo_tests) {
    my $file    = "resources/solaris/psrinfo/$test";
    my @results = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_getCPUFromPsrinfo(file => $file);
    is_deeply(\@results, $psrinfo_tests{$test}, "psrinfo parsing: $test" );
}

foreach my $test (keys %spec_tests) {
    my @results = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_parseSpec($test);
    is_deeply(\@results, $spec_tests{$test}, "spec parsing: $test" );
}
