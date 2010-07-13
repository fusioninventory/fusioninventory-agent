#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;
use Test::More;

my %tests = (
    'freebsd-6.2' => [
        {
            NUMSLOTS    => 1,
            SERIALNUMBER => 'None',
            DESCRIPTION => 'DIMM',
            SPEED       => 'Unknown',
            TYPE        => 'Unknown',
            CAPTION     => 'A0',
            CAPACITY    => '512'
        }
    ],
    'linux-2.6' => [
        {
            NUMSLOTS    => 1,
            SERIALNUMBER => '02132010',
            DESCRIPTION => 'DIMM',
            SPEED       => '533 MHz (1.9 ns)',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM_A',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 2,
            SERIALNUMBER => '02132216',
            DESCRIPTION => 'DIMM',
            SPEED       => '533 MHz (1.9 ns)',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM_B',
            CAPACITY    => '1024'
        }
    ],
    'openbsd-3.7' => undef,
    'openbsd-3.8' => [
        {
            NUMSLOTS    => 1,
            SERIALNUMBER => '50075483',
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM1_A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 2,
            SERIALNUMBER => '500355A1',
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM1_B',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 3,
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM2_A',
            CAPACITY    => 'No'
        },
        {
            NUMSLOTS    => 4,
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM2_B',
            CAPACITY    => 'No'
        },
        {
            NUMSLOTS    => 5,
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM3_A',
            CAPACITY    => 'No'
        },
        {
            NUMSLOTS    => 6,
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM3_B',
            CAPACITY    => 'No'
        }
    ],
    'rhel-2.1' => undef,
    'rhel-3.4' => [
        {
            NUMSLOTS    => 1,
            SERIALNUMBER => '460360BB',
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM 1',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 2,
            SERIALNUMBER => '460360E8',
            DESCRIPTION => 'DIMM',
            SPEED       => '400 MHz (2.5 ns)',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM 2',
            CAPACITY    => '512'
        }
    ],
    'rhel-4.3' => [
        {
            NUMSLOTS    => 1,
            DESCRIPTION => 'DIMM',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM1',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 2,
            DESCRIPTION => 'DIMM',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM2',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 3,
            DESCRIPTION => 'DIMM',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM3',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 4,
            DESCRIPTION => 'DIMM',
            TYPE        => 'DDR',
            CAPTION     => 'DIMM4',
            CAPACITY    => '512'
        }
    ],
    'rhel-4.6' => [
        {
            NUMSLOTS    => 1,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 1A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 2,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 2B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 3,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 3C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 4,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => 'Unknown',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 4D',
            CAPACITY    => 'No'
        },
        {
            NUMSLOTS    => 5,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 5A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS    => 6,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 6B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 7,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => '667 MHz (1.5 ns)',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 7C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS    => 8,
            DESCRIPTION => '<OUT OF SPEC>',
            SPEED       => 'Unknown',
            TYPE        => '<OUT OF SPEC>',
            CAPTION     => 'DIMM 8D',
            CAPACITY    => 'No'
        }
    ],
    'windows' => [
        {
            NUMSLOTS    => 1,
            DESCRIPTION => 'SODIMM',
            SPEED       => 'Unknown',
            TYPE        => 'SDRAM',
            CAPTION     => 'DIMM 0',
            CAPACITY    => '256'
        },
        {
            NUMSLOTS    => 2,
            DESCRIPTION => 'SODIMM',
            SPEED       => 'Unknown',
            TYPE        => 'SDRAM',
            CAPTION     => 'DIMM 1',
            CAPACITY    => '512'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory::parseDmidecode($file, '<');
    is_deeply($memories, $tests{$test}, $test);
}
