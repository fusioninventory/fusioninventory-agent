#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't';

use English qw(-no_match_vars);
use Test::Deep;
use Test::MockModule;
use Test::More;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::CPU;

my %tests = (
    '7' => [
        {
            ID           => 'A7 06 02 00 FF FB EB BF',
            NAME         => 'Intel(R) Core(TM) i5-2300 CPU @ 2.80GHz',
            SERIAL       => 'ToBeFilledByO.E.M.',
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 6 Model 42 Stepping 7',
            STEPPING     => '7',
            FAMILYNUMBER => '6',
            MODEL        => '42',
            SPEED        => '2800',
            THREAD       => undef,
            CORE         => '4'
        }
    ],
    '2003' => [
        {
            ID           => 'BFEBFBFF00000F29',
            NAME         => 'Intel(R) Xeon(TM) CPU 3.06GHz',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 15 Model 2 Stepping 9',
            STEPPING     => '9',
            FAMILYNUMBER => '15',
            MODEL        => '2',
            SPEED        => '3060',
            THREAD       => undef,
            CORE         => undef
        },
        {
            ID           => '0000000000000000',
            NAME         => 'Intel(R) Xeon(TM) CPU 3.06GHz',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 15 Model 2 Stepping 9',
            STEPPING     => '9',
            FAMILYNUMBER => '15',
            MODEL        => '2',
            SPEED        => '3060',
            THREAD       => undef,
            CORE         => undef
        }
    ],
    '2003SP2' => [
        {
            ID           => '0FEBBBFF00010676',
            NAME         => 'Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 6 Model 23 Stepping 6',
            STEPPING     => '6',
            FAMILYNUMBER => '6',
            MODEL        => '23',
            SPEED        => '2830',
            THREAD       => undef,
            CORE         => undef
        },
        {
            ID           => '0FEBBBFF00000676',
            NAME         => 'Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 6 Model 23 Stepping 6',
            STEPPING     => '6',
            FAMILYNUMBER => '6',
            MODEL        => '23',
            SPEED        => '2830',
            THREAD       => undef,
            CORE         => undef
        }
    ],
    'xp' => [
        {
            ID           => '76 06 01 00 FF FB EB BF',
            NAME         => 'Intel(R) Core(TM)2 Duo CPU     T9400  @ 2.53GHz',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            DESCRIPTION  => 'x86 Family 6 Model 23 Stepping 6',
            STEPPING     => '6',
            FAMILYNUMBER => '6',
            MODEL        => '23',
            SPEED        => '2530',
            THREAD       => '2',
            CORE         => '2'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::CPU'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    $module->mock(
        'getCpusFromDmidecode',
        sub {
            my $file = "resources/generic/dmidecode/windows-$test";
            return
                -f $file ?
                FusionInventory::Agent::Tools::Generic::getCpusFromDmidecode(
                    file => $file
                ) : ();
        }
    );

    $module->mock(
        'getRegistryKey',
        mockGetRegistryKey($test)
    );

    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Win32::CPU::_getCPUs();
    cmp_deeply(
        \@cpus,
        $tests{$test},
        "$test sample"
    );
}
