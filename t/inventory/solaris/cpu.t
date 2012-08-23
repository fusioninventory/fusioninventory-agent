#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU;

my %vpcu_tests = (
    unstable9s  => [ 24, { speed => '1165', type => 'sparcv9' } ],
    unstable9x  => [  4, { speed => '2333', type => 'i386'    } ],
    unstable10s => [ 24, { speed => '1165', type => 'sparcv9' } ],
    unstable10x => [  4, { speed => '2333', type => 'i386'    } ],
);

my %pcpu_tests = (
    unstable9s => [ 
        1,
        { speed => '1165', type => 'UltraSPARC-T2', count => 24 }
    ],
    unstable9x => [ 
        4,
        { type => 'i386', count => 1 }
    ],
    unstable10s => [ 
        1,
        { speed => '1165', type => 'UltraSPARC-T2', count => 24 }
    ],
    unstable10x => [ 
        4,
        { speed => '2333', type => 'x86', count => 1 }
    ],
);

plan tests => 
    2 * (scalar keys %vpcu_tests) +
    2 * (scalar keys %pcpu_tests) ;

foreach my $test (keys %vpcu_tests) {
    my $file = "resources/solaris/psrinfo/$test-psrinfo_v";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_getVirtualCPUs(file => $file);
    is(scalar @cpus,    $vpcu_tests{$test}->[0], "virtual cpus count: $test");
    is_deeply($cpus[0], $vpcu_tests{$test}->[1], "virtual cpus values: $test");
}

foreach my $test (keys %pcpu_tests) {
    my $file = "resources/solaris/psrinfo/$test-psrinfo_vp";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_getPhysicalCPUs(file => $file);
    is(scalar @cpus,    $pcpu_tests{$test}->[0], "physical cpus count: $test" );
    is_deeply($cpus[0], $pcpu_tests{$test}->[1], "physical cpus values: $test");
}
