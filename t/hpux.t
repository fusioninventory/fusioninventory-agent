#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;
use Test::More;
use FindBin;

use Data::Dumper;

my %cpu_tests = (
    'hpux_11.31_3xia64' => {
        'CPUcount' => '3',
        'SPEED' => '1600',
        'NAME'  => 'Itanium',
        'MANUFACTURER' => 'Intel',
    },
    'hpux_11.23.ia64' => {
        'CPUcount' => '2',
        'NAME'  => 'Itanium',
        'MANUFACTURER' => 'Intel',
        'SPEED' => '1600'
    },
    'hpux_11.31-1' => {
        'NAME' => 'Itanium',
        'CPUcount' => '3',
        'MANUFACTURER' => 'Intel',
        'SPEED' => '1600'
    },
    'hpux_11.31-2' => {
        'NAME' => 'Itanium',
        'CPUcount' => '2',
        'CORE' => 4,
        'MANUFACTURER' => 'Intel',
        'SPEED' => '1730'
    },
    'hpux_11.31-3' => {
        'NAME' => 'Itanium',
        'CPUcount' => '2',
        'MANUFACTURER' => 'Intel',
        'SPEED' => '1600'
    },
    'hpux_11.31-superdome' => {
        'NAME' => 'Itanium',
        'CPUcount' => 1,
        'MANUFACTURER' => 'Intel',
        'SPEED' => '1600',
        'CORE' => '2'
    }

);

my $cpropCpu = [
          {
            'ID' => 'ff-ff-ff-3-ff-0-ff-11',
            'NAME' => 'Itanium',
            'MANUFACTURER' => 'Intel',
            'SPEED' => '1729',
            'CORE' => 4
          },
          {
            'ID' => 'ff-ff-ff-4-ff-0-ff-11',
            'NAME' => 'Itanium',
            'MANUFACTURER' => 'Intel',
            'SPEED' => '1729',
            'CORE' => 4
          }
];


my $cpropMem = [
          [
            {
              'SERIALNUMBER' => 'f9d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'cad94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '2fd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '6cd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '72d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'aed94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'cbd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '27d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'fed94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'fdd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'd0d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '71d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'a7d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '26d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'e8d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '46da4044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'e3d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '2ed94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '2dd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'a6d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '67d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'cfd94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => 'e7d94044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            },
            {
              'SERIALNUMBER' => '4cda4044271001',
              'DESCRIPTION' => 'M393B5270CH0-CH9',
              'TYPE' => 'DIMM',
              'CAPACITY' => 4000
            }
          ],
          96000

];

plan tests => (scalar keys %cpu_tests) + 2;

foreach my $test (keys %cpu_tests) {
    my $file = "$FindBin::Bin/../resources/machinfo/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseMachinInfo($file, '<');
    is_deeply($cpu_tests{$test}, $results, $test) or print Dumper($results);
}

my $cpus = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseCpropProcessor('resources/hpux/cpu/cprop/hpux-11.31-1', '<');
is_deeply($cpus, $cpropCpu, '_parseCpropProcessor') or print Dumper($cpus);


my @mems = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseCpropMemory('resources/hpux/memory/cprop/11.31-1', '<');
is_deeply(\@mems, $cpropMem, '_parseCpropMemory') or print Dumper(\@mems);
