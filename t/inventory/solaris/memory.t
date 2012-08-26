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

plan tests => ( scalar keys %memconf_class1_tests );

foreach my $test ( keys %memconf_class1_tests ) {
    my $file = "resources/solaris/memconf/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Input::Solaris::Memory::_getMemories1(
        file => $file );
    is_deeply(
        \@results,
        $memconf_class1_tests{$test},
        "memconf parsing: $test"
    );
}

