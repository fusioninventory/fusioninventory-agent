#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;
use Test::More;
use File::Glob;
use File::Basename;

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

my @list = glob("resources/machinfo/*");
plan tests => int @list;

foreach my $file (@list) {
    my $results = FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU::_parseMachinInfo($file, '<');
    is_deeply($cpu_tests{basename($file)}, $results, basename($file)) or print Dumper($results);
}


