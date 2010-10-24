#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'freebsd-6.2' => {
        bios => {
            SMODEL        => 'CN700-8237R',
            SSN           => 'A9-06-00-00-FF-BB-C9-A7',
            SMANUFACTURER => undef,
            BDATE         => undef,
            BVERSION      => undef,
            BMANUFACTURER => undef,
            ASSETTAG      => undef
        },
        hardware => {
            UUID     => undef,
        }
    },
    'freebsd-8.1' => {
        bios => {
            SMANUFACTURER => 'Hewlett-Packard',
            SMODEL        => 'HP Pavilion dv6 Notebook PC',
            SSN           => 'CNF01207X6',
            BDATE         => '05/17/2010',
            ASSETTAG      => undef,
            BVERSION      => 'F.1C',
            BMANUFACTURER => 'Hewlett-Packard'
        },
        hardware => {
            UUID => '30464E43-3231-3730-5836-C80AA93F35FA'
        },
    },
    'linux-2.6' => {
        bios => {
            SMANUFACTURER => 'Dell Inc.',
            SMODEL        => 'Latitude D610',
            SSN           => 'D8XD62J',
            BMANUFACTURER => 'Dell Inc.',
            BVERSION      => 'A06',
            BDATE         => '10/02/2005',
            ASSETTAG      => undef
        },
        hardware => {
            UUID     => '44454C4C-3800-1058-8044-C4C04F36324A',
        }
    },
    'openbsd-3.7' => {
        bios => {
            SMANUFACTURER => 'VIA Technologies, Inc.',
            SMODEL        => 'VT82C691',
            SSN           => '52-06-00-00-FF-F9-83-01',
            BMANUFACTURER => 'Award Software International, Inc.',
            BVERSION      => '4.51 PG',
            BDATE         => '02/11/99',
            ASSETTAG      => undef
        },
        hardware => {
            UUID     => undef,
        }
    },
    'openbsd-3.8' => {
        bios => {
            SMANUFACTURER => 'Dell Computer Corporation',
            SMODEL        => 'PowerEdge 1800',
            SSN           => '2K1012J',
            BMANUFACTURER => 'Dell Computer Corporation',
            BVERSION      => 'A05',
            BDATE         => '09/21/2005',
            ASSETTAG      => undef
        },
        hardware => {
            UUID     => '44454C4C-4B00-1031-8030-B2C04F31324A',
        }
    },
    'rhel-2.1' => {
        bios => {
            SMANUFACTURER => 'IBM',
            SMODEL        => '-[84803AX]-',
            SSN           => 'KBKGW40',
            BMANUFACTURER => 'IBM',
            BVERSION      => '-[JPE130AUS-1.30]-',
            BDATE         => undef,
            ASSETTAG      => undef
        },
        hardware => {
            UUID     => undef,
        }
    },
    'rhel-3.4' => {
        bios => {
            ASSETTAG      => '12345678901234567890123456789012',
            SMANUFACTURER => 'IBM',
            SMODEL        => 'IBM eServer x226-[8488PCR]-',
            SSN           => 'KDXPC16',
            BMANUFACTURER => 'IBM',
            BVERSION      => 'IBM BIOS Version 1.57-[PME157AUS-1.57]-',
            BDATE         => '08/25/2005'
        },
        hardware => {
            UUID     => 'A8346631-8E88-3AE3-898C-F3AC9F61C316',
        }
    },
    'rhel-4.3' => {
        bios => {
            SMANUFACTURER => 'IBM',
            SMODEL        => '-[86494jg]-',
            SSN           => 'KDMAH1Y',
            BMANUFACTURER => 'IBM',
            BVERSION      => '-[OQE115A]-',
            BDATE         => '03/14/2006',
            ASSETTAG      => undef
        },
        hardware => {
            UUID => '0339D4C3-44C0-9D11-A20E-85CDC42DE79C',
        }
    },
    'rhel-4.6' => {
        bios => {
            SMANUFACTURER => 'HP',
            SMODEL        => 'ProLiant ML350 G5',
            SSN           => 'GB8814HE7S',
            BMANUFACTURER => 'HP',
            BVERSION      => 'D21',
            BDATE         => '01/24/2008',
            ASSETTAG      => undef
        },
        hardware => {
            UUID => '34313236-3435-4742-3838-313448453753',
        }
    },
    'windows' => {
        bios => {
            SMANUFACTURER => 'TOSHIBA',
            SMODEL        => 'Satellite 2410',
            SSN           => 'X2735244G',
            BMANUFACTURER => 'TOSHIBA',
            BVERSION      => 'Version 1.10',
            BDATE         => '08/13/2002',
            ASSETTAG      => '0000000000',
        },
        hardware => {
            UUID     => '7FB4EA00-07CB-18F3-8041-CAD582735244',
        }
    }
);

plan tests => (scalar keys %tests) * 2;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my ($bios, $hardware) = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios::_getBiosHardware($logger, $file);
    is_deeply($bios, $tests{$test}->{bios}, $test);
    is_deeply($hardware, $tests{$test}->{hardware}, $test);

}
