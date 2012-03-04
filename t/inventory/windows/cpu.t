#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::CPU;

my %tests = (
    7 => [
        {
            ID           => 'A7 06 02 00 FF FB EB BF',
            NAME         => 'Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz',
            SERIAL       => 'ToBeFilledByO.E.M.',
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 6 Model 42 Stepping 7',
            SPEED        => '2800',
            THREAD       => undef,
            CORE         => '4'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::CPU'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWmiObjects',
        mockGetWmiObjects($test)
    );

    $module->mock(
        'getCpusFromDmidecode',
        sub {
            return
                FusionInventory::Agent::Tools::Generic::getCpusFromDmidecode(
                    file => "resources/generic/dmidecode/windows-$test"
                );
        }
    );

    $module->mock(
        'getRegistryKey',
        mockGetRegistryKey($test)
    );

    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Win32::CPU::_getCPUs();
    is_deeply(
        \@cpus,
        $tests{$test},
        "$test cpu"
    );
}
