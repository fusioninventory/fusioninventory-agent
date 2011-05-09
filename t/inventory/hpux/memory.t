#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;

my %tests = (
    'hppa-1' => []
);

my %tests64 = (
    'ia64-1' => [
        {
            NUMSLOTS    => '0A',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 0A',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '0B',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 0B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '0C',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 0C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '0D',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 0D',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '1A',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 1A',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '1B',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 1B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '1C',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 1C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '1D',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 1D',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => '2A',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 2A',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '2B',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 2B',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '2C',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 2C',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '2D',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 2D',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '3A',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 3A',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '3B',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 3B',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '3C',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 3C',
            CAPACITY    => '----'
        },
        {
            NUMSLOTS    => '3D',
            DESCRIPTION => 'DIMM',
            TYPE        => 'DIMM',
            CAPTION     => 'DIMM 3D',
            CAPACITY    => '----'
        }
    ],
);

my $cpropMem = [
    {
        SERIALNUMBER => 'f9d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'cad94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '2fd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '6cd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '72d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'aed94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'cbd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '27d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'fed94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'fdd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'd0d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '71d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'a7d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '26d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'e8d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '46da4044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'e3d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '2ed94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '2dd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'a6d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '67d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'cfd94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => 'e7d94044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    },
    {
        SERIALNUMBER => '4cda4044271001',
        DESCRIPTION  => 'M393B5270CH0-CH9',
        TYPE         => 'DIMM',
        CAPACITY     => 4000
    }
];

plan tests =>
    (scalar keys %tests) + 
    (scalar keys %tests64) +
    1;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/cstm/$test";
    my @memories = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseCstm(file => $file);
    is_deeply(\@memories, $tests{$test}, "memories: $test");
}

foreach my $test (keys %tests64) {
    my $file = "resources/hpux/cstm/$test";
    my @memories = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseCstm64(file => $file);
    is_deeply(\@memories, $tests64{$test}, "memories: $test");
}

my @memories = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseCprop(file => 'resources/hpux/cprop/memory');
is_deeply(\@memories, $cpropMem, 'cprop output parsing');
