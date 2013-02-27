#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::MockModule;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Solaris::CPU;

my %vpcu_tests = (
    unstable9s  => [ _map(24, { speed => '1165', type => 'sparcv9' }) ],
    unstable9x  => [ _map( 4, { speed => '2333', type => 'i386'    }) ],
    unstable10s => [ _map(24, { speed => '1165', type => 'sparcv9' }) ],
    unstable10x => [ _map( 4, { speed => '2333', type => 'i386'    }) ],
    unstable11s => [ _map( 4, { speed => '1165', type => 'sparcv9' }) ],
    unstable11x => [ _map( 4, { speed => '2326', type => 'i386'    }) ],
    giration    => [ _map(16, { speed => '1350', type => 'sparcv9' }) ],
    v240        => [ _map( 2, { speed => '1280', type => 'sparcv9' }) ],
    v490        => [ _map( 8, { speed => '1350', type => 'sparcv9' }) ],
    t5120       => [ _map(32, { speed => '1165', type => 'sparcv9' }) ],
    e6900       => [
        _map(8, { speed => '1350', type => 'sparcv9' }) ,
        _map(4, { speed =>  '900', type => 'sparcv9' }) ,
        _map(8, { speed => '1350', type => 'sparcv9' }) ,
    ],
);

my %pcpu_tests = (
    unstable9s => [
        _map(1, { speed => '1165', type => 'UltraSPARC-T2', count => 24 })
    ],
    unstable9x => [
        _map(4, { type => 'i386', count => 1 })
    ],
    unstable10s => [
        _map(1, { speed => '1165', type => 'UltraSPARC-T2', count => 24 })
    ],
    unstable10x => [
        _map(4, { speed => '2333', type => 'Xeon E5410', count => 1 })
    ],
    unstable11s => [
        _map(1, { speed => '1165', type => 'UltraSPARC-T2', count => 4 })
    ],
    unstable11x => [
        _map(4, { speed => '2326', type => 'Xeon E5410', count => 1 })
    ],
    giration => [
        _map(8, { speed => '1350', type => 'UltraSPARC-IV', count => 2 })
    ],
    v240 => [
        _map(2, { type => 'UltraSPARC-IIIi', count => 1 })
    ],
    v490 => [
        _map(4, { speed => '1350', type => 'UltraSPARC-IV', count => 2 })
    ],
    t5120 => [
        _map(1, { speed => '1165', type => 'UltraSPARC-T2', count => 32 })
    ],
    e6900 => [
        _map(8, { speed => '1350', type => 'UltraSPARC-IV'  , count => 2 }),
        _map(4, { speed =>  '900', type => 'UltraSPARC-III+', count => 1 }),
    ],
);

my %cpu_tests = (
    unstable9s => [
        _map(1,
            {
                NAME         => 'UltraSPARC-T2',
                MANUFACTURER => 'SPARC',
                SPEED        => '1165',
                THREAD       => 8,
                CORE         => 3
            }
        )
    ],
    unstable9x => [
        _map(4,
            {
                NAME         => 'i386',
                MANUFACTURER => undef,
                SPEED        => '2333',
                THREAD       => 1,
                CORE         => 1
            }
        )
    ],
    unstable10s => [
        _map(1,
            {
                NAME         => 'UltraSPARC-T2',
                MANUFACTURER => 'SPARC',
                SPEED        => '1165',
                THREAD       => 8,
                CORE         => 3
            }
        )
    ],
    unstable10x => [
        _map(4,
            {
                NAME         => 'Xeon E5410',
                MANUFACTURER => 'Intel',
                SPEED        => '2333',
                THREAD       => 1,
                CORE         => 1
            }
        )
    ],
    unstable11s => [
        _map(1,
            {
                NAME         => 'UltraSPARC-T2',
                MANUFACTURER => 'SPARC',
                SPEED        => '1165',
                THREAD       => 8,
                CORE         => 0.5
            }
        )
    ],
    unstable11x => [
        _map(4,
            {
                NAME         => 'Xeon E5410',
                MANUFACTURER => 'Intel',
                SPEED        => '2326',
                THREAD       => 1,
                CORE         => 1
            }
        )
    ],
    giration => [
        _map(8,
            {
                NAME         => 'UltraSPARC-IV',
                MANUFACTURER => 'SPARC',
                SPEED        => '1350',
                THREAD       => 1,
                CORE         => 2
            }
        )
    ],
    v240 => [
        _map(2,
            {
                NAME         => 'UltraSPARC-IIIi',
                MANUFACTURER => 'SPARC',
                SPEED        => '1280',
                THREAD       => 1,
                CORE         => 1
            }
        )
    ],
    v490 => [
        _map(4,
            {
                NAME         => 'UltraSPARC-IV',
                MANUFACTURER => 'SPARC',
                SPEED        => '1350',
                THREAD       => 1,
                CORE         => 2
            }
        )
    ],
    t5120 => [
        _map(1,
            {
                NAME         => 'UltraSPARC-T2',
                MANUFACTURER => 'SPARC',
                SPEED        => 1165,
                THREAD       => 8,
                CORE         => 4
            }
        )
    ]
);

plan tests =>
    (scalar keys %vpcu_tests) +
    (scalar keys %pcpu_tests) +
    (scalar keys %cpu_tests) ;

foreach my $test (keys %vpcu_tests) {
    my $file = "resources/solaris/psrinfo/$test-psrinfo_v";
    my @cpus = FusionInventory::Agent::Task::Inventory::Solaris::CPU::_getVirtualCPUs(file => $file);
    cmp_deeply(\@cpus, $vpcu_tests{$test}, "virtual cpus: $test");
}

foreach my $test (keys %pcpu_tests) {
    my $file = "resources/solaris/psrinfo/$test-psrinfo_vp";
    my @cpus = FusionInventory::Agent::Task::Inventory::Solaris::CPU::_getPhysicalCPUs(file => $file);
    cmp_deeply(\@cpus, $pcpu_tests{$test}, "physical cpus: $test");
}

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Solaris::CPU'
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

    my @cpus = FusionInventory::Agent::Task::Inventory::Solaris::CPU::_getCPUs();
    cmp_deeply(\@cpus, $cpu_tests{$test}, "cpus values: $test");
}


sub _map {
    my ($count, $object) = @_;
    return map { $object } 1 .. $count;
}
