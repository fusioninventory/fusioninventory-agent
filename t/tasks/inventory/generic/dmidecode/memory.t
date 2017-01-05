#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Memory;

my %tests = (
    'freebsd-6.2' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => undef,
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
            DESCRIPTION      => 'SODIMM',
            TYPE             => undef,
            SPEED            => '1067 MHz',
            CAPACITY         => '2048',
            CAPTION          => 'Bottom - Slot 1',
            MANUFACTURER     => 'Hynix',
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '1A554239',
            DESCRIPTION      => 'SODIMM',
            TYPE             => undef,
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            TYPE             => undef,
        },
        {
            NUMSLOTS         => 2,
            TYPE             => 'DIMM SDRAM',
            CAPACITY         => '64'
        },
        {
            NUMSLOTS         => 3,
            TYPE             => undef,
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
            TYPE             => undef,
        },
        {
            NUMSLOTS         => 7,
            TYPE             => undef,
        }
    ],
    'openbsd-3.8' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '50075483',
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM1_A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '500355A1',
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM1_B',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM2_A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM2_B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM3_A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            SPEED            => '400 MHz (2.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM3_B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        }
    ],
    'openbsd-4.5' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DDR',
            SPEED            => '266 MHz',
            CAPTION          => 'DIMM D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'

        }
    ],
    'oracle-server-x5-2' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '330DC586',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D11',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '32A3A4FD',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D10',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D9',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => '330DC585',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D8',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => '32A3A500',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D7',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D6',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => '330DC584',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D0',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => '32A3A4BD',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D1',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => '330DC588',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D3',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => '32A3A50E',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D4',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D5',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 13,
            SERIALNUMBER     => '330DC582',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D11',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 14,
            SERIALNUMBER     => '32A3A4CE',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D10',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 15,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D9',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 16,
            SERIALNUMBER     => '330DCB4F',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D8',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 17,
            SERIALNUMBER     => '32A3A4FC',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D7',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 18,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D6',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 19,
            SERIALNUMBER     => '330DC543',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D0',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 20,
            SERIALNUMBER     => '32A3A4CC',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D1',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 21,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 22,
            SERIALNUMBER     => '330DC52C',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D3',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 23,
            SERIALNUMBER     => '32A3A50D',
            DESCRIPTION      => 'DIMM',
            SPEED            => '2133 MHz',
            TYPE             => 'DDR4',
            CAPTION          => 'D4',
            CAPACITY         => '32768',
            MANUFACTURER     => 'Samsung',
            MEMORYCORRECTION => 'Multi-bit ECC'
        },
        {
            NUMSLOTS         => 24,
            SERIALNUMBER     => 'NO DIMM',
            DESCRIPTION      => 'DIMM',
            SPEED            => undef,
            TYPE             => 'DDR4',
            CAPTION          => 'D5',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 1A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 2B',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 3C',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => undef,
            TYPE             => undef,
            CAPTION          => 'DIMM 4D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 5A',
            CAPACITY         => '512',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 6B',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => '667 MHz (1.5 ns)',
            TYPE             => undef,
            CAPTION          => 'DIMM 7C',
            CAPACITY         => '1024',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => undef,
            DESCRIPTION      => undef,
            SPEED            => undef,
            TYPE             => undef,
            CAPTION          => 'DIMM 8D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        }
    ],
    'hp-dl180' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '94D657D7',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => '1333 MHz (0.8 ns)',
            CAPACITY         => '2048',
            CAPTION          => 'PROC 1 DIMM 2A',
            MANUFACTURER     => 'Micron',
            MEMORYCORRECTION => 'Single-bit ECC'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'SerNum01',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 1 DIMM 1D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => '93D657D7',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => '1333 MHz (0.8 ns)',
            CAPACITY         => '2048',
            CAPTION          => 'PROC 1 DIMM 4B',
            MANUFACTURER     => 'Micron',
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'SerNum03',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 1 DIMM 3E',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => 'SerNum04',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 1 DIMM 6C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => 'SerNum05',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 1 DIMM 5F',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => 'SerNum06',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 2A',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => 'SerNum07',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 1D',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => 'SerNum08',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 4B',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => 'SerNum09',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 3E',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => 'SerNum10',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 6C',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => 'SerNum11',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            CAPTION          => 'PROC 2 DIMM 5F',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'Single-bit ECC'
        }
    ],
    'S3000AHLX' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => '0x750174F7',
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DDR2',
            SPEED            => undef,
            CAPTION          => 'J9J2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'S5000VSA' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPACITY         => '2048',
            CAPTION          => 'RAM slot #0',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'

        }
    ],
    'vmware-esx' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPACITY         => '2048',
            CAPTION          => 'RAM slot #0',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #1',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #2',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #3',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #4',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #5',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #6',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #7',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #8',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #9',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #10',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #11',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 13,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #12',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 14,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
            CAPTION          => 'RAM slot #13',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 15,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'DIMM',
            TYPE             => 'DRAM',
            SPEED            => undef,
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
            DESCRIPTION      => 'SODIMM',
            SPEED            => undef,
            TYPE             => 'SDRAM',
            CAPTION          => 'DIMM 0',
            CAPACITY         => '256',
            MANUFACTURER     => undef,
            MEMORYCORRECTION => 'None'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => undef,
            DESCRIPTION      => 'SODIMM',
            SPEED            => undef,
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
            DESCRIPTION      => 'DIMM',
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
            DESCRIPTION      => 'DIMM',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        }
    ],
    'windows-7' => [
        {
            NUMSLOTS         => 1,
            MEMORYCORRECTION => 'None',
            SERIALNUMBER     => 'SerNum0',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            MANUFACTURER     => undef,
            CAPTION          => 'DIMM0'
        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => '0000000',
            TYPE             => undef,
            SPEED            => '1600 MHz',
            CAPTION          => 'DIMM1',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        },
        {
            NUMSLOTS         => 3,
            MEMORYCORRECTION => 'None',
            SERIALNUMBER     => 'SerNum2',
            DESCRIPTION      => 'DIMM',
            TYPE             => undef,
            SPEED            => undef,
            MANUFACTURER     => undef,
            CAPTION          => 'DIMM2'
        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => '0000000',
            TYPE             => undef,
            SPEED            => '1600 MHz',
            CAPTION          => 'DIMM3',
            MEMORYCORRECTION => 'None',
            DESCRIPTION      => 'DIMM',
            MANUFACTURER     => undef,
            CAPACITY         => '2048'
        }
    ],
    'windows-hyperV' => [
        {
            NUMSLOTS         => 1,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPACITY         => '1024',
            CAPTION          => 'M0',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 2,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M1',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 3,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M2',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 4,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M3',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 5,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M4',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 6,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M5',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 7,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M6',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 8,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M7',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 9,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M8',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 10,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M9',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 11,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M10',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 12,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M11',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 13,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M12',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 14,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M13',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 15,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M14',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 16,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M15',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 17,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M16',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 18,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M17',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 19,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M18',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 20,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M19',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 21,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M20',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 22,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M21',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 23,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M22',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 24,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M23',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 25,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M24',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 26,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M25',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 27,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M26',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 28,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M27',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 29,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M28',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 30,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M29',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 31,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M30',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 32,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M31',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 33,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M32',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 34,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M33',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 35,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M34',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 36,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M35',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 37,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M36',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 38,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M37',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 39,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M38',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 40,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M39',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 41,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M40',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 42,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M41',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 43,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M42',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 44,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M43',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 45,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M44',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 46,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M45',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 47,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M46',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 48,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M47',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 49,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M48',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 50,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M49',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 51,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M50',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 52,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M51',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 53,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M52',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 54,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M53',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 55,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M54',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 56,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M55',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 57,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M56',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 58,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M57',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 59,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M58',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 60,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M59',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 61,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M60',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 62,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M61',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 63,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M62',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        },
        {
            NUMSLOTS         => 64,
            SERIALNUMBER     => 'None',
            DESCRIPTION      => undef,
            TYPE             => 'Other',
            SPEED            => undef,
            CAPTION          => 'M63',
            MANUFACTURER     => 'Microsoft',
            MEMORYCORRECTION => 'None'

        }
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Memory::_getMemories(file => $file);
    cmp_deeply($memories, $tests{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'MEMORIES', entry => $_)
            foreach @$memories;
    } "$test: registering";
}
