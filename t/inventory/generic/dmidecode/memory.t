#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use File::Basename;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory;

my %tests = (
    'freebsd-6.2' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'DIMM',
            SPEED        => 'Unknown',
            TYPE         => 'Unknown',
            CAPTION      => 'A0',
            CAPACITY    => '512'
        }
    ],
    'freebsd-8.1' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '1A1541FC',
            DESCRIPTION  => 'SODIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => '1067 MHz',
            CAPACITY     => '2048',
            CAPTION      => 'Bottom - Slot 1'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => '1A554239',
            DESCRIPTION  => 'SODIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => '1067 MHz',
            CAPACITY     => '2048',
            CAPTION      => 'Bottom - Slot 2'
        }
    ],
    'linux-2.6' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '02132010',
            DESCRIPTION  => 'DIMM',
            SPEED        => '533 MHz (1.9 ns)',
            TYPE         => 'DDR',
            CAPTION      => 'DIMM_A',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => '02132216',
            DESCRIPTION  => 'DIMM',
            SPEED        => '533 MHz (1.9 ns)',
            TYPE         => 'DDR',
            CAPTION      => 'DIMM_B',
            CAPACITY    => '1024'
        }
    ],
    'openbsd-3.7' => undef,
    'openbsd-3.8' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '50075483',
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM1_A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => '500355A1',
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM1_B',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM2_A',
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM2_B',
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM3_A',
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM3_B',
        }
    ],
    'rhel-2.1' => undef,
    'rhel-3.4' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '460360BB',
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => 'DDR',
            CAPTION      => 'DIMM 1',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => '460360E8',
            DESCRIPTION  => 'DIMM',
            SPEED        => '400 MHz (2.5 ns)',
            TYPE         => 'DDR',
            CAPTION      => 'DIMM 2',
            CAPACITY    => '512'
        }
    ],
    'rhel-4.3' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => undef,
            TYPE         => 'DDR',
            CAPTION      => 'DIMM1',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => undef,
            TYPE         => 'DDR',
            CAPTION      => 'DIMM2',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => undef,
            TYPE         => 'DDR',
            CAPTION      => 'DIMM3',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            SPEED        => undef,
            TYPE         => 'DDR',
            CAPTION      => 'DIMM4',
            CAPACITY    => '512'
        }
    ],
    'rhel-4.6' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 1A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 2B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 3C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 4D',
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 5A',
            CAPACITY    => '512'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 6B',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => '667 MHz (1.5 ns)',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 7C',
            CAPACITY    => '1024'
        },
        {
            NUMSLOTS     => 8,
            SERIALNUMBER => undef,
            DESCRIPTION  => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            TYPE         => '<OUT OF SPEC>',
            CAPTION      => 'DIMM 8D',
        }
    ],
    'windows' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'SODIMM',
            SPEED        => 'Unknown',
            TYPE         => 'SDRAM',
            CAPTION      => 'DIMM 0',
            CAPACITY    => '256'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'SODIMM',
            SPEED        => 'Unknown',
            TYPE         => 'SDRAM',
            CAPTION      => 'DIMM 1',
            CAPACITY    => '512'
        }
    ],
    'hp-dl180' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '94D657D7',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => '1333 MHz (0.8 ns)',
            CAPACITY     => '2048',
            CAPTION      => 'PROC 1 DIMM 2A'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => 'SerNum01',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 1 DIMM 1D'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => '93D657D7',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => '1333 MHz (0.8 ns)',
            CAPACITY     => '2048',
            CAPTION      => 'PROC 1 DIMM 4B'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => 'SerNum03',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 1 DIMM 3E'
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => 'SerNum04',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 1 DIMM 6C'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => 'SerNum05',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 1 DIMM 5F'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => 'SerNum06',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 2A'
        },
        {
            NUMSLOTS     => 8,
            SERIALNUMBER => 'SerNum07',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 1D'
        },
        {
            NUMSLOTS     => 9,
            SERIALNUMBER => 'SerNum08',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 4B'
        },
        {
            NUMSLOTS     => 10,
            SERIALNUMBER => 'SerNum09',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 3E'
        },
        {
            NUMSLOTS     => 11,
            SERIALNUMBER => 'SerNum10',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 6C'
        },
        {
            NUMSLOTS     => 12,
            SERIALNUMBER => 'SerNum11',
            DESCRIPTION  => 'DIMM',
            TYPE         => '<OUT OF SPEC>',
            SPEED        => 'Unknown',
            CAPTION      => 'PROC 2 DIMM 5F'
        }
    ],
    'linux-1' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => 'SerNum00',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '1066 MHz',
            CAPACITY     => '1024',
            CAPTION      => 'DIMM0'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => 'SerNum01',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '1066 MHz',
            CAPACITY     => '1024',
            CAPTION      => 'DIMM1'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => 'SerNum02',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '1066 MHz',
            CAPACITY     => '1024',
            CAPTION      => 'DIMM2'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => 'SerNum03',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '1066 MHz',
            CAPACITY     => '1024',
            CAPTION      => 'DIMM3'
        }
    ],
    'openbsd-4.5' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR',
            SPEED        => '266 MHz',
            CAPACITY     => '512',
            CAPTION      => 'DIMM A'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR',
            SPEED        => '266 MHz',
            CAPTION      => 'DIMM B'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR',
            SPEED        => '266 MHz',
            CAPTION      => 'DIMM C'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR',
            SPEED        => '266 MHz',
            CAPTION      => 'DIMM D'
        }
    ],
    'S3000AHLX' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => '0x750174F7',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '533 MHz (1.9 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'J8J1'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => '0x9DCCE4ED',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '533 MHz (1.9 ns)',
            CAPACITY     => '2048',
            CAPTION      => 'J8J2'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => '0x750174FF',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '533 MHz (1.9 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'J9J1'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => 'NO DIMM',
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => 'Unknown',
            CAPTION      => 'J9J2'
        }
    ],
    'S5000VSA' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_A1'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_A2'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_A3'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_A4'
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_B1'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_B2'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_B3'
        },
        {
            NUMSLOTS     => 8,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DDR2',
            SPEED        => '667 MHz (1.5 ns)',
            CAPACITY     => '1024',
            CAPTION      => 'ONBOARD DIMM_B4'
        }
    ],
    'esx-2.5' => [
        {
            NUMSLOTS     => 1,
            TYPE         => 'EDO DIMM',
            CAPACITY     => '1024'
        },
        {
            NUMSLOTS     => 2,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 3,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 4,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 5,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 6,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 7,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 8,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 9,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 10,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 11,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 12,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 13,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 14,
            TYPE         => 'DIMM'
        },
        {
            NUMSLOTS     => 15,
            TYPE         => 'DIMM'
        }
    ],
    'rhel-2.1' => [
        {
            NUMSLOTS     => 1,
            TYPE         => 'ECC DIMM SDRAM',
            CAPACITY     => '256'
        },
        {
            NUMSLOTS     => 2,
            TYPE         => 'UNKNOWN'
        }
    ],
    'openbsd-3.7' => [
        {
            NUMSLOTS     => 1,
            TYPE         => 'Unknown'
        },
        {
            NUMSLOTS     => 2,
            TYPE         => 'DIMM SDRAM',
            CAPACITY     => '64'
        },
        {
            NUMSLOTS     => 3,
            TYPE         => 'Unknown'
        },
        {
            NUMSLOTS     => 4,
            TYPE         => 'DIMM SDRAM',
            CAPACITY     => '64'
        },
        {
            NUMSLOTS     => 5,
            TYPE         => 'DIMM SDRAM',
            CAPACITY     => '64'
        },
        {
            NUMSLOTS     => 6,
            TYPE         => 'Unknown'
        },
        {
            NUMSLOTS     => 7,
            TYPE         => 'Unknown'
        }
    ],
    'vmware' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPACITY     => '2048',
            CAPTION      => 'RAM slot #0'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #1'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #2'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #3'
        }
    ],
    'dmidecode-esx' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPACITY     => '2048',
            CAPTION      => 'RAM slot #0'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #1'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #2'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #3'
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #4'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #5'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #6'
        },
        {
            NUMSLOTS     => 8,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #7'
        },
        {
            NUMSLOTS     => 9,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #8'
        },
        {
            NUMSLOTS     => 10,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #9'
        },
        {
            NUMSLOTS     => 11,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #10'
        },
        {
            NUMSLOTS     => 12,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #11'
        },
        {
            NUMSLOTS     => 13,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #12'
        },
        {
            NUMSLOTS     => 14,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #13'
        },
        {
            NUMSLOTS     => 15,
            SERIALNUMBER => undef,
            DESCRIPTION  => 'DIMM',
            TYPE         => 'DRAM',
            SPEED        => 'Unknown',
            CAPTION      => 'RAM slot #14'
        }
    ]
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory::_getMemories($logger, $file);
    is_deeply($memories, $tests{$test}, $test);
}
