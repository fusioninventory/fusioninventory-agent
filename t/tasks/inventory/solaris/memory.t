#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory;

my %memconf_fire_tests = (
    'fire-sample1' => [
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 0',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board A MemCtl 2',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 1',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '0',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPTION     => 'Board B MemCtl 3',
            CAPACITY    => 256
        }
    ]
);

my %memconf_firev_tests = (
    'firev-sample1' => [
        {
            NUMSLOTS => '0',
            CAPACITY => '512',
            CAPTION => 'MB/P0/B0/D0'
        },
        {
            NUMSLOTS => '0',
            CAPACITY => '512',
            CAPTION  => 'MB/P0/B0/D1'
        },
        {
            NUMSLOTS => '1',
            CAPACITY => '512',
            CAPTION  => 'MB/P1/B0/D0'
        },
        {
            NUMSLOTS => '1',
            CAPACITY => '512',
            CAPTION  => 'MB/P1/B0/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/P0/B1/D0'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/P0/B1/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/P1/B1/D0'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/P1/B1/D1'
        }
    ]
);

my %memconf_firet_tests = (
    'firet-sample1' => [
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '32',
            CAPTION     => 'DIMM1'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '32',
            CAPTION     => 'DIMM2'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '32',
            CAPTION     => 'DIMM3'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '32',
            CAPTION     => 'DIMM4'
        }
    ],
    'firet-sample2' => [
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB0/CH0/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB0/CH1/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB1/CH0/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB1/CH1/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB2/CH0/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB2/CH1/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB3/CH0/D0'
        },
        {
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'MB/CMP0/BOB3/CH1/D0'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB0/CH1/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB1/CH1/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB2/CH1/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB3/CH1/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB0/CH0/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB1/CH0/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB2/CH0/D1'
        },
        {
            DESCRIPTION => 'empty',
            CAPTION     => 'MB/CMP0/BOB3/CH0/D1'
        }
    ]
);

my %memconf_i86pc_tests = (
    'i86pc-sample1' => [
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '4',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '5',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '6',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '7',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '8',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board A'
        },
        {
            NUMSLOTS    => '1',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '2',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '3',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '4',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '5',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '6',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '7',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        },
        {
            NUMSLOTS    => '8',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '2048',
            CAPTION     => 'Board B'
        }
    ],
    'i86pc-sample2' => [
        {
            CAPTION     => 'cpu0.mem0',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '1024'
        },
        {
            CAPTION     => 'cpu0.mem1',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '1024'
        },
        {
            CAPTION     => 'cpu1.mem0',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '1024'
        },
        {
            CAPTION     => 'cpu1.mem1',
            DESCRIPTION => 'DIMM',
            CAPACITY    => '1024'
        },
        {
            CAPTION     => 'cpu0.mem2',
            DESCRIPTION => 'empty',
        },
        {
            CAPTION     => 'cpu0.mem3',
            DESCRIPTION => 'empty',
        },
        {
            CAPTION     => 'cpu1.mem2',
            DESCRIPTION => 'empty',
        },
        {
            CAPTION     => 'cpu1.mem3',
            DESCRIPTION => 'empty',
        }

    ]
);

plan tests => 
    (scalar keys %memconf_fire_tests) +
    (scalar keys %memconf_firev_tests) +
    (scalar keys %memconf_firet_tests) +
    (scalar keys %memconf_i86pc_tests) ;


foreach my $test (keys %memconf_fire_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemoriesFire(file => $file);
    cmp_deeply(
        \@results,
        $memconf_fire_tests{$test},
        "memconf parsing: $test"
    );
}

foreach my $test (keys %memconf_firev_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemoriesFireV(file => $file);
    cmp_deeply(
        \@results,
        $memconf_firev_tests{$test},
        "memconf parsing: $test"
    );
}

foreach my $test (keys %memconf_firet_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemoriesFireT(file => $file);
    cmp_deeply(
        \@results,
        $memconf_firet_tests{$test},
        "memconf parsing: $test"
    );
}

foreach my $test (keys %memconf_i86pc_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemoriesI86PC(file => $file);
    cmp_deeply(
        \@results,
        $memconf_i86pc_tests{$test},
        "memconf parsing: $test"
    );
}
