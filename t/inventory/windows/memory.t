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

use FusionInventory::Agent::Task::Inventory::Input::Win32::Memory;

my %tests = (
    '7' => [
        {
            NUMSLOTS     => 0,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => '0000000',
            TYPE         => 'Unknown',
            SPEED        => '1600',
            CAPTION      => "Mémoire physique",
            REMOVABLE    => 0,
            DESCRIPTION  => "Mémoire physique",
            CAPACITY     => '2048'
        },
        {
            NUMSLOTS     => 1,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => '0000000',
            TYPE         => 'Unknown',
            SPEED        => '1600',
            CAPTION      => "Mémoire physique",
            REMOVABLE    => 0,
            DESCRIPTION  => "Mémoire physique",
            CAPACITY     => '2048'
        }
    ],
    'xp' => [
        {
            NUMSLOTS     => 0,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => undef,
            TYPE         => 'Unknown',
            SPEED        => '800',
            CAPTION      => 'Physical Memory',
            REMOVABLE    => 0,
            DESCRIPTION  => 'Physical Memory',
            CAPACITY     => '2048'
        },
        {
            NUMSLOTS     => 1,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => undef,
            TYPE         => 'Unknown',
            SPEED        => '800',
            CAPTION      => 'Physical Memory',
            REMOVABLE    => 0,
            DESCRIPTION  => 'Physical Memory',
            CAPACITY     => '2048'
        }
      ],
    '2003' => [
        {
            NUMSLOTS     => 0,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => undef,
            TYPE         => 'Unknown',
            SPEED        => '266',
            CAPTION      => 'Physical Memory',
            REMOVABLE    => 0,
            DESCRIPTION  => 'Physical Memory',
            CAPACITY     => '1024'
        },
        {
            NUMSLOTS     => 1,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => undef,
            TYPE         => 'Unknown',
            SPEED        => '266',
            CAPTION      => 'Physical Memory',
            REMOVABLE    => 0,
            DESCRIPTION  => 'Physical Memory',
            CAPACITY     => '1024'
        }
      ],
    '2003SP2' => [
        {
            NUMSLOTS     => 0,
            FORMFACTOR   => 'DIMM',
            SERIALNUMBER => undef,
            TYPE         => 'DRAM',
            SPEED        => undef,
            CAPTION      => 'Physical Memory',
            REMOVABLE    => 0,
            DESCRIPTION  => 'Physical Memory',
            CAPACITY     => '1024'
        }
    ]
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::Memory'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWmiObjects',
        mockGetWmiObjects($test)
    );

    my @memories = FusionInventory::Agent::Task::Inventory::Input::Win32::Memory::_getMemories();
    is_deeply(
        \@memories,
        $tests{$test},
        "$test sample"
    );
}
