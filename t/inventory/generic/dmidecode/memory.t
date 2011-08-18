#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

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
    'vmware-esx' => [
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
    ],
    'vmware-esx-2.5' => [
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
    'windows-hyperV' => [
        {
            NUMSLOTS     => 1,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPACITY     => '1024',
            CAPTION      => 'M0'
        },
        {
            NUMSLOTS     => 2,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M1'
        },
        {
            NUMSLOTS     => 3,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M2'
        },
        {
            NUMSLOTS     => 4,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M3'
        },
        {
            NUMSLOTS     => 5,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M4'
        },
        {
            NUMSLOTS     => 6,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M5'
        },
        {
            NUMSLOTS     => 7,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M6'
        },
        {
            NUMSLOTS     => 8,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M7'
        },
        {
            NUMSLOTS     => 9,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M8'
        },
        {
            NUMSLOTS     => 10,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M9'
        },
        {
            NUMSLOTS     => 11,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M10'
        },
        {
            NUMSLOTS     => 12,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M11'
        },
        {
            NUMSLOTS     => 13,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M12'
        },
        {
            NUMSLOTS     => 14,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M13'
        },
        {
            NUMSLOTS     => 15,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M14'
        },
        {
            NUMSLOTS     => 16,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M15'
        },
        {
            NUMSLOTS     => 17,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M16'
        },
        {
            NUMSLOTS     => 18,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M17'
        },
        {
            NUMSLOTS     => 19,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M18'
        },
        {
            NUMSLOTS     => 20,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M19'
        },
        {
            NUMSLOTS     => 21,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M20'
        },
        {
            NUMSLOTS     => 22,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M21'
        },
        {
            NUMSLOTS     => 23,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M22'
        },
        {
            NUMSLOTS     => 24,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M23'
        },
        {
            NUMSLOTS     => 25,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M24'
        },
        {
            NUMSLOTS     => 26,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M25'
        },
        {
            NUMSLOTS     => 27,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M26'
        },
        {
            NUMSLOTS     => 28,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M27'
        },
        {
            NUMSLOTS     => 29,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M28'
        },
        {
            NUMSLOTS     => 30,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M29'
        },
        {
            NUMSLOTS     => 31,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M30'
        },
        {
            NUMSLOTS     => 32,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M31'
        },
        {
            NUMSLOTS     => 33,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M32'
        },
        {
            NUMSLOTS     => 34,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M33'
        },
        {
            NUMSLOTS     => 35,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M34'
        },
        {
            NUMSLOTS     => 36,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M35'
        },
        {
            NUMSLOTS     => 37,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M36'
        },
        {
            NUMSLOTS     => 38,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M37'
        },
        {
            NUMSLOTS     => 39,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M38'
        },
        {
            NUMSLOTS     => 40,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M39'
        },
        {
            NUMSLOTS     => 41,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M40'
        },
        {
            NUMSLOTS     => 42,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M41'
        },
        {
            NUMSLOTS     => 43,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M42'
        },
        {
            NUMSLOTS     => 44,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M43'
        },
        {
            NUMSLOTS     => 45,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M44'
        },
        {
            NUMSLOTS     => 46,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M45'
        },
        {
            NUMSLOTS     => 47,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M46'
        },
        {
            NUMSLOTS     => 48,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M47'
        },
        {
            NUMSLOTS     => 49,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M48'
        },
        {
            NUMSLOTS     => 50,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M49'
        },
        {
            NUMSLOTS     => 51,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M50'
        },
        {
            NUMSLOTS     => 52,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M51'
        },
        {
            NUMSLOTS     => 53,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M52'
        },
        {
            NUMSLOTS     => 54,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M53'
        },
        {
            NUMSLOTS     => 55,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M54'
        },
        {
            NUMSLOTS     => 56,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M55'
        },
        {
            NUMSLOTS     => 57,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M56'
        },
        {
            NUMSLOTS     => 58,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M57'
        },
        {
            NUMSLOTS     => 59,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M58'
        },
        {
            NUMSLOTS     => 60,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M59'
        },
        {
            NUMSLOTS     => 61,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M60'
        },
        {
            NUMSLOTS     => 62,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M61'
        },
        {
            NUMSLOTS     => 63,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M62'
        },
        {
            NUMSLOTS     => 64,
            SERIALNUMBER => 'None',
            DESCRIPTION  => 'Unknown',
            TYPE         => 'Other',
            SPEED        => 'Unknown',
            CAPTION      => 'M63'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $memories = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Memory::_getMemories(file => $file);
    is_deeply($memories, $tests{$test}, $test);
}
