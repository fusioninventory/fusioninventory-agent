#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;

my %tests = (
    'hppa-1' => 1920,
    'ia64-1' => 8192 
);

my $cpropMem = [
    [
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
    ],
    96000
];

plan tests => (scalar keys %tests) + 1;

foreach my $test (keys %tests) {
    my @lines = getAllLines(file => "resources/hpux/memory/cstm/$test");

    my $result = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseMemory(\@lines);
    is($result, $tests{$test}, $test);
}

my @mems = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseCpropMemory('resources/hpux/memory/cprop/11.31-1', '<');
is_deeply(\@mems, $cpropMem, '_parseCpropMemory');
