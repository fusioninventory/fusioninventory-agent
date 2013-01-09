#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Memory;

my %tests = (
    'freebsd-6.2' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'DIMM (None)',
            SPEED            => 'Unknown',
            TYPE             => 'Unknown',
            CAPTION          => 'A0',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'freebsd-8.1' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '1A1541FC',
            DESCRIPTION      => 'SODIMM (None)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1067 MHz',
            CAPACITY         => '2048',
            CAPTION          => 'Bottom - Slot 1',
            MANUFACTURER     => 'Hynix',
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '1A554239',
            DESCRIPTION      => 'SODIMM (None)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1067 MHz',
            CAPACITY         => '2048',
            CAPTION          => 'Bottom - Slot 2',
            MANUFACTURER     => 'Hynix',
            MEMORYCORRECTION => 'None'

        }
    ],
    'linux-1' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => 'SerNum00',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '1066 MHz',
            CAPACITY         => '1024',
            CAPTION          => 'DIMM0',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'SerNum01',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '1066 MHz',
            CAPACITY         => '1024',
            CAPTION          => 'DIMM1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => 'SerNum02',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '1066 MHz',
            CAPACITY         => '1024',
            CAPTION          => 'DIMM2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'SerNum03',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '1066 MHz',
            CAPACITY         => '1024',
            CAPTION          => 'DIMM3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'linux-2.6' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '02132010',
            DESCRIPTION      => 'DIMM (None)',
            SPEED            => '533 MHz (1.9 ns)',
            TYPE             => 'DDR',
            CAPTION          => 'DIMM_A',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '02132216',
            DESCRIPTION      => 'DIMM (None)',
            SPEED            => '533 MHz (1.9 ns)',
            TYPE             => 'DDR',
            CAPTION          => 'DIMM_B',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        }
    ],
    'openbsd-3.7' => [
        {
            NUMSLOTS         => 1,
            TYPE             => 'Unknown'
        },
        {
            NUMSLOTS         => 2,
            TYPE             => 'DIMM SDRAM',
            CAPACITY         => '64'
        },
        {
            NUMSLOTS         => 3,
            TYPE             => 'Unknown'
        },
        {
            NUMSLOTS         => 4,
            TYPE             => 'DIMM SDRAM',
            CAPACITY         => '64'
        },
        {
            NUMSLOTS         => 5,
            TYPE             => 'DIMM SDRAM',
            CAPACITY         => '64'
        },
        {
            NUMSLOTS         => 6,
            TYPE             => 'Unknown'
        },
        {
            NUMSLOTS         => 7,
            TYPE             => 'Unknown'
        }
    ],
    'openbsd-3.8' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '50075483',
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM1_A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '500355A1',
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM1_B',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM2_A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM2_B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM3_A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM3_B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        }
    ],
    'openbsd-4.5' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPACITY         => '512',
            CAPTION          => 'DIMM A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        }
    ],
    'rhel-2.1' => [
        {
            NUMSLOTS         => 1,
            TYPE             => 'ECC DIMM SDRAM',
            CAPACITY         => '256'
        },
        {
            NUMSLOTS         => 2,
            TYPE             => 'UNKNOWN'
        }
    ],
    'rhel-3.4' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '460360BB',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => 'DDR',
            CAPTION          => 'DIMM 1',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '460360E8',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => 'DDR',
            CAPTION          => 'DIMM 2',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        }
    ],
    'rhel-4.3' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => undef,
            TYPE             => 'DDR',
            CAPTION          => 'DIMM1',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => undef,
            TYPE             => 'DDR',
            CAPTION          => 'DIMM2',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => undef,
            TYPE             => 'DDR',
            CAPTION          => 'DIMM3',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            SPEED            => undef,
            TYPE             => 'DDR',
            CAPTION          => 'DIMM4',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        }
    ],
    'rhel-4.6' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 1A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 2B',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 3C',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => 'Unknown',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 4D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 5A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 6B',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 7C',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => undef,
            DESCRIPTION      => '<OUT OF SPEC> (Single-bit ECC)',
            SPEED            => 'Unknown',
            TYPE             => '<OUT OF SPEC>',
            CAPTION          => 'DIMM 8D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        }
    ],
    'hp-dl180' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '94D657D7',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1333 MHz (0.8 ns)',
            CAPACITY         => '2048',
            CAPTION          => 'PROC 1 DIMM 2A',
            MANUFACTURER     => 'Micron',
            MEMORYCORRECTION => 'Single-bit ECC'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'SerNum01',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 1 DIMM 1D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => '93D657D7',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1333 MHz (0.8 ns)',
            CAPACITY         => '2048',
            CAPTION          => 'PROC 1 DIMM 4B',
            MANUFACTURER     => 'Micron',
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'SerNum03',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 1 DIMM 3E',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => 'SerNum04',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 1 DIMM 6C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => 'SerNum05',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 1 DIMM 5F',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => 'SerNum06',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 2A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => 'SerNum07',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 1D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => 'SerNum08',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 4B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => 'SerNum09',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 3E',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => 'SerNum10',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 6C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => 'SerNum11',
            DESCRIPTION      => 'DIMM (Single-bit ECC)',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => 'Unknown',
            CAPTION          => 'PROC 2 DIMM 5F',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        }
    ],
    'S3000AHLX' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '0x750174F7',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '533 MHz (1.9 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'J8J1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '0x9DCCE4ED',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '533 MHz (1.9 ns)',
            CAPACITY         => '2048',
            CAPTION          => 'J8J2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => '0x750174FF',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => '533 MHz (1.9 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'J9J1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DDR2',
            SPEED            => 'Unknown',
            CAPTION          => 'J9J2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'S5000VSA' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_A1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_A2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_A3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_A4',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_B1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_B2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_B3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (Multi-bit ECC)',
            TYPE             => 'DDR2',
            SPEED            => '667 MHz (1.5 ns)',
            CAPACITY         => '1024',
            CAPTION          => 'ONBOARD DIMM_B4',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        }
    ],
    'vmware' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPACITY         => '2048',
            CAPTION          => 'RAM slot #0',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'vmware-esx' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPACITY         => '2048',
            CAPTION          => 'RAM slot #0',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #4',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #5',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #6',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #7',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #8',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #9',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #10',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #11',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 13,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #12',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 14,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #13',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 15,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'DRAM',
            SPEED            => 'Unknown',
            CAPTION          => 'RAM slot #14',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        }
    ],
    'vmware-esx-2.5' => [
        {
            NUMSLOTS         => 1,
            TYPE             => 'EDO DIMM',
            CAPACITY         => '1024',
        },
        {
            NUMSLOTS         => 2,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 3,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 4,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 5,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 6,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 7,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 8,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 9,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 10,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 11,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 12,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 13,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 14,
            TYPE             => 'DIMM'
        },
        {
            NUMSLOTS         => 15,
            TYPE             => 'DIMM'
        }
    ],
    'windows' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'SODIMM (None)',
            SPEED            => 'Unknown',
            TYPE             => 'SDRAM',
            CAPTION          => 'DIMM 0',
            CAPACITY         => '256',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'SODIMM (None)',
            SPEED            => 'Unknown',
            TYPE             => 'SDRAM',
            CAPTION          => 'DIMM 1',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        }
    ],
    'windows-xp' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '14FA6621',
            TYPE             => 'DDR2',
            SPEED            => '800 MHz',
            CAPTION          => 'DIMM_A',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM (None)',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'AEF96621',
            TYPE             => 'DDR2',
            SPEED            => '800 MHz',
            CAPTION          => 'DIMM_B',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM (None)',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        }
    ],
    'windows-7' => [
        {
            NUMSLOTS         => 1,
            MEMORYCORRECTION => 'None',
            SERIALNUMBER     => 'SerNum0',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'Unknown',
            SPEED            => 'Unknown',
            MANUFACTURER     => undef,
            CAPTION          => 'DIMM0'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '0000000',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1600 MHz',
            CAPTION          => 'DIMM1',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM (None)',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        },
        {
            NUMSLOTS         => 3,
            MEMORYCORRECTION => 'None',
            SERIALNUMBER     => 'SerNum2',
            DESCRIPTION      => 'DIMM (None)',
            TYPE             => 'Unknown',
            SPEED            => 'Unknown',
            MANUFACTURER     => undef,
            CAPTION          => 'DIMM2'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => '0000000',
            TYPE             => '<OUT OF SPEC>',
            SPEED            => '1600 MHz',
            CAPTION          => 'DIMM3',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM (None)',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        }
    ],
    'windows-hyperV' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPACITY         => '1024',
            CAPTION          => 'M0',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M1',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M2',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M3',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M4',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M5',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M6',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M7',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M8',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M9',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M10',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M11',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 13,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M12',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 14,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M13',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 15,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M14',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 16,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M15',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 17,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M16',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 18,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M17',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 19,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M18',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 20,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M19',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 21,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M20',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 22,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M21',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 23,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M22',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 24,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M23',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 25,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M24',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 26,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M25',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 27,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M26',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 28,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M27',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 29,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M28',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 30,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M29',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 31,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M30',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 32,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M31',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 33,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M32',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 34,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M33',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 35,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M34',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 36,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M35',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 37,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M36',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 38,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M37',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 39,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M38',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 40,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M39',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 41,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M40',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 42,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M41',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 43,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M42',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 44,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M43',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 45,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M44',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 46,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M45',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 47,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M46',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 48,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M47',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 49,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M48',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 50,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M49',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 51,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M50',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 52,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M51',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 53,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M52',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 54,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M53',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 55,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M54',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 56,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M55',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 57,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M56',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 58,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M57',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 59,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M58',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 60,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M59',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 61,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M60',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 62,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M61',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 63,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M62',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 64,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'Unknown (None)',
            TYPE             => 'Other',
            SPEED            => 'Unknown',
            CAPTION          => 'M63',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Memory::_getMemories(file => $file);
    cmp_deeply($memories, $tests{$test}, $test);
}
