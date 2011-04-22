#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;

use Test::More;

my %tests = (
    'hpux_11.31_3xia64' => {
        CPUcount     => '3',
        SPEED        => '1600',
        NAME         => 'Itanium',
        MANUFACTURER => 'Intel',
    },
    'hpux_11.23.ia64' => {
        CPUcount     => '2',
        NAME         => 'Itanium',
        MANUFACTURER => 'Intel',
        SPEED       => '1600'
    },
    'hpux_11.31-1' => {
        NAME         => 'Itanium',
        CPUcount     => '3',
        MANUFACTURER => 'Intel',
        SPEED        => '1600'
    },
    'hpux_11.31-2' => {
        NAME         => 'Itanium',
        CPUcount     => '2',
        CORE         => 4,
        MANUFACTURER => 'Intel',
        SPEED        => '1730'
    },
    'hpux_11.31-3' => {
        NAME         => 'Itanium',
        CPUcount     => '2',
        MANUFACTURER => 'Intel',
        SPEED        => '1600'
    },
    'hpux_11.31-superdome' => {
        NAME         => 'Itanium',
        CPUcount     => 1,
        MANUFACTURER => 'Intel',
        SPEED        => '1600',
        CORE         => '2'
    }
);

my $cpropCpu = [
    {
        ID           => 'ff-ff-ff-3-ff-0-ff-11',
        NAME         => 'Itanium',
        MANUFACTURER => 'Intel',
        SPEED        => '1729',
        CORE         => 4
    },
    {
        ID           => 'ff-ff-ff-4-ff-0-ff-11',
        NAME         => 'Itanium',
        MANUFACTURER => 'Intel',
        SPEED        => '1729',
        CORE         => 4
    }
];

plan tests => (scalar keys %tests) + 1;

foreach my $test (keys %tests) {
    my $file = "resources/machinfo/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseMachinInfo(file => $file);
    is_deeply($results, $tests{$test}, $test);
}

my $cpus = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseCpropProcessor(file => 'resources/cprop/cpu');
is_deeply($cpus, $cpropCpu, '_parseCpropProcessor');
