#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::MockModule;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU;

my %vpcu_tests = (
    unstable9s  => [ 24, { speed => '1165', type => 'sparcv9' } ],
    unstable9x  => [  4, { speed => '2333', type => 'i386'    } ],
    unstable10s => [ 24, { speed => '1165', type => 'sparcv9' } ],
    unstable10x => [  4, { speed => '2333', type => 'i386'    } ],
    unstable11s => [  4, { speed => '1165', type => 'sparcv9' } ],
    unstable11x => [  4, { speed => '2326', type => 'i386'    } ],
    giration    => [ 16, { speed => '1350', type => 'sparcv9' } ],
    v240        => [  2, { speed => '1280', type => 'sparcv9' } ],
    v490        => [  8, { speed => '1350', type => 'sparcv9' } ],
    t5120       => [ 32, { speed => '1165', type => 'sparcv9' } ],
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
    v240 => [
        2,
        { type => 'UltraSPARC-IIIi', count => 1 }
    ],
    v490 => [
        4,
        { speed => '1350', type => 'UltraSPARC-IV', count => 2 }
    ],
    t5120 => [
        1,
        { speed => '1165', type => 'UltraSPARC-T2', count => 32 }
    ],
);

my %cpu_tests = (
    unstable9s => [
        1,
        { 
            NAME         => 'UltraSPARC-T2',
            MANUFACTURER => 'SPARC',
            SPEED        => '1165',
            THREAD       => 8,
            CORE         => 3
        }
    ],
    unstable9x => [
        4,
        { 
            NAME         => 'i386',
            MANUFACTURER => undef,
            SPEED        => '2333',
            THREAD       => 1,
            CORE         => 1
        }
    ],
    unstable10s => [
        1,
        {
            NAME         => 'UltraSPARC-T2',
            MANUFACTURER => 'SPARC',
            SPEED        => '1165',
            THREAD       => 8,
            CORE         => 3
        }
    ],
    unstable10x => [
        4,
        { 
            NAME         => 'Xeon E5410',
            MANUFACTURER => 'Intel',
            SPEED        => '2333',
            THREAD       => 1,
            CORE         => 1
        }
    ],
    unstable11s => [
        1,
        { 
            NAME         => 'UltraSPARC-T2',
            MANUFACTURER => 'SPARC',
            SPEED        => '1165',
            THREAD       => 8,
            CORE         => 0.5
        }
    ],
    unstable11x => [
        4,
        { 
            NAME         => 'Xeon E5410',
            MANUFACTURER => 'Intel',
            SPEED        => '2326',
            THREAD       => 1,
            CORE         => 1
        }
    ],
    giration => [
        8,
        {
            NAME         => 'UltraSPARC-IV',
            MANUFACTURER => 'SPARC',
            SPEED        => '1350',
            THREAD       => 1,
            CORE         => 2
        }
    ],
    v240 => [
        2,
        {
            NAME         => 'UltraSPARC-IIIi',
            MANUFACTURER => 'SPARC',
            SPEED        => '1280',
            THREAD       => 1,
            CORE         => 1
        }
    ],
    v490 => [
        4,
        { 
            NAME         => 'UltraSPARC-IV',
            MANUFACTURER => 'SPARC',
            SPEED        => '1350',
            THREAD       => 1,
            CORE         => 2
        }
    ],
    t5120 => [
        1,
        {
            NAME         => 'UltraSPARC-T2',
            MANUFACTURER => 'SPARC',
            SPEED        => 1165,
            THREAD       => 8,
            CORE         => 4
        }
    ]
);

plan tests => 
    2 * (scalar keys %vpcu_tests) +
    2 * (scalar keys %pcpu_tests) +
    2 * (scalar keys %cpu_tests) ;

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

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU'
);

foreach my $test (keys %cpu_tests) {
    $module->mock(
        '_getVirtualCPUs',
        sub {
            my $original = $module->original('_getVirtualCPUs');
            return $original->(
                file => "resources/solaris/psrinfo/$test-psrinfo_v"
            );
        }
    );

    $module->mock(
        '_getPhysicalCPUs',
        sub {
            my $original = $module->original('_getPhysicalCPUs');
            return $original->(
                file => "resources/solaris/psrinfo/$test-psrinfo_vp"
            );
        }
    );

    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Solaris::CPU::_getCPUs();
    is(scalar @cpus,    $cpu_tests{$test}->[0], "cpus count: $test" );
    is_deeply($cpus[0], $cpu_tests{$test}->[1], "cpus values: $test");
}

