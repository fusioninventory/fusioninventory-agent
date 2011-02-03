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
        'TYPE'  => 'Itanium',
        'MANUFACTURER' => 'Intel',
    },
    'hpux_11.23.ia64' => {
        'CPUcount' => '2',
        'TYPE'  => 'Itanium',
        'MANUFACTURER' => 'Intel',
        'TYPE' => 'Itanium',
        'SPEED' => '1600'
    }

);

plan tests => (scalar keys %cpu_tests);

foreach my $test (keys %cpu_tests) {
    my $file = "$FindBin::Bin/../resources/machinfo/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseMachinInfo($file, '<');
    is_deeply($cpu_tests{$test}, $results, $test) or print Dumper($results);
}


