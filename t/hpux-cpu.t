#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;
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

    }

);

my $cprop = [
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

plan tests => (scalar keys %cpu_tests);

foreach my $test (keys %cpu_tests) {
    my $file = "$FindBin::Bin/../resources/machinfo/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseMachinInfo($file, '<');
    is_deeply($cpu_tests{$test}, $results, $test) or print Dumper($results);
}

my $cpus = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseCpropProcessor('resources/hpux/cpu/cprop/hpux-11.31-1', '<');
is_deeply($cpus, $cprop, '_parseCpropProcessor') or print Dumper($cpus);

