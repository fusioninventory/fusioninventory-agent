#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory;

my %memconf_class1_tests = (
    sample5 => [
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

my %memconf_class6_tests = (
    sample1 => [
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
    ]
);

plan tests => 
    (scalar keys %memconf_class1_tests) +
    (scalar keys %memconf_class6_tests) ;


foreach my $test (keys %memconf_class1_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemories1(file => $file);
    is_deeply(
        \@results,
        $memconf_class1_tests{$test},
        "memconf parsing: $test"
    );
}

foreach my $test (keys %memconf_class6_tests) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemories6(file => $file);
    is_deeply(
        \@results,
        $memconf_class6_tests{$test},
        "memconf parsing: $test"
    );
}
