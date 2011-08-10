#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU;

my %testParseMemconf = (
    sample4 => {
        'NAME'         => 'Opteron(tm) Processor 270',
        'MANUFACTURER' => 'AMD',
        'SPEED'        => '1993',
        'CORE'         => 2
    },
    sample2 => {
        'NAME'         => 'UltraSPARC-IIi',
        'MANUFACTURER' => 'Sun Microsystems',
        'SPEED'        => '270',
        'CORE'         => 1
    },
    sample1 => {
        'NAME'         => 'Xeon(R) E7320',
        'MANUFACTURER' => 'Intel',
        'SPEED'        => '2130',
        'CORE'         => 4
    },
);

my %testParseSpec = (

'Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)'
      => [
        1,
        {
            'NAME'         => 'UltraSPARC-T1 (8-core quad-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1000',
            'THREAD'       => 4,
            'CORE'         => '8'
        }
      ],
    'Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)' => [
        '4',
        {
            'NAME'         => 'UltraSPARC-III',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '750',
            'CORE'         => 1
        }
    ],
'Sun Microsystems, Inc. SPARC Enterprise T5120 (8-core 8-thread UltraSPARC-T2 1165MHz)'
      => [
        1,
        {
            'NAME'         => 'UltraSPARC-T2 (8-core 8-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1165',
            'THREAD'       => '8',
            'CORE'         => '8'
        }
      ],
    'Sun Microsystems, Inc. Sun Fire V240 (UltraSPARC-IIIi 1002MHz)' => [
        'UltraSPARC-IIIi',
        {
            'NAME'         => 'UltraSPARC-IIIi',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1002',
            'CORE'         => 1
        }
    ],
'Sun Microsystems, Inc. Sun SPARC Enterprise M5000 Server (6 X dual-core dual-thread SPARC64-VI 2150MHz)'
      => [
        '6',
        {
            'NAME'         => 'SPARC64-VI (dual-core dual-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '2150',
            'THREAD'       => 2,
            'CORE'         => 2
        }
      ],
    'Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)'
      => [
        '2',
        {
            'NAME'         => 'UltraSPARC-IV (dual-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1350',
            'THREAD'       => 2,
            'CORE'         => '2'
        }
      ],
'Sun Microsystems, Inc. Sun Fire V20z (Solaris x86 machine) (2 X Dual Core AMD Opteron(tm) Processor 270 1993MHz)'
      => [
        '2',
        {
            'NAME'         => 'Opteron(tm) Processor 270',
            'MANUFACTURER' => 'AMD',
            'SPEED'        => '1993',
            'CORE'         => 2
        }
      ],
'Fujitsu SPARC Enterprise M4000 Server (4 X dual-core dual-thread SPARC64-VI 2150MHz)'
      => [
        '4',
        {
            'NAME'         => 'SPARC64-VI (dual-core dual-thread)',
            'MANUFACTURER' => 'Fujitsu',
            'SPEED'        => '2150',
            'THREAD'       => 2,
            'CORE'         => 2
        }
      ],
'Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (4-core quad-thread UltraSPARC-T1 1000MHz)'
      => [
        1,
        {
            'NAME'         => 'UltraSPARC-T1 (4-core quad-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1000',
            'THREAD'       => 4,
            'CORE'         => '4'
        }
      ],
'Sun Microsystems, Inc. SPARC Enterprise T5120 (4-core 8-thread UltraSPARC-T2 1165MHz)'
      => [
        1,
        {
            'NAME'         => 'UltraSPARC-T2 (4-core 8-thread)',
            'MANUFACTURER' => 'Sun Microsystems',
            'SPEED'        => '1165',
            'THREAD'       => '8',
            'CORE'         => '4'
        }
      ]

);

plan tests => scalar keys(%testParseMemconf) + scalar keys(%testParseSpec);

foreach my $test ( keys %testParseMemconf ) {
    my $r =
      FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU::_getCPUFromMemconf(
        undef, './resources/solaris/memconf/' . $test );
    use Data::Dumper;
    is_deeply( $r, $testParseMemconf{$test}, "parse memconf: $test" )
      or print Dumper($r);

}
use Data::Dumper;
foreach my $test ( keys %testParseSpec ) {
    my @ret =
      FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU::_parseSpec(
        $test);
    is_deeply( \@ret, $testParseSpec{$test}, "parseSpec: $test" ) or print Dumper(\@ret)

}
