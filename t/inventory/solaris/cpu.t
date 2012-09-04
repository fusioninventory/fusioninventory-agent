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
    unstable11s => [  4, { speed => '1165', type => 'sparcv9' } ],
    unstable11x => [  4, { speed => '2326', type => 'i386'    } ],
    giration    => [ 16, { speed => '1350', type => 'sparcv9' } ],
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
        { speed => '2333', type => 'Xeon E5410', count => 1 }
    ],
    unstable11s => [
        1,
        { speed => '1165', type => 'UltraSPARC-T2', count => 4 }
    ],
    unstable11x => [
        4,
        { speed => '2326', type => 'Xeon E5410', count => 1 }
    ],
    giration => [
        8,
        { speed => '1350', type => 'UltraSPARC-IV', count => 2 }
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
