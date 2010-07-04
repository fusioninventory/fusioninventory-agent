#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use Test::More;
use FindBin;

my %tests = (
    'dmidecode-freebsd-6.2' => {
        SMANUFACTURER => ' ',
        SMODEL        => ' ',
        SSN           => ' ',
    },
    'dmidecode-linux-2.6' => {
        ASSETTAG           => '',
        SMANUFACTURER => 'Dell Inc.',
        SMODEL        => 'Latitude D610',
        SSN           => 'D8XD62J',
        BMANUFACTURER => 'Dell Inc.',
        BVERSION      => 'A06',
        BDATE         => '10/02/2005'
    },
    'dmidecode-openbsd-3.7' => {
        SMANUFACTURER => 'VIA Technologies, Inc.',
        SMODEL        => 'VT82C691',
        SSN           => '52-06-00-00-FF-F9-83-01',
        BMANUFACTURER => 'Award Software International, Inc.',
        BVERSION      => '4.51 PG',
        BDATE         => '02/11/99'
    },
    'dmidecode-openbsd-3.8' => {
        ASSETTAG           => '',
        SMANUFACTURER => 'Dell Computer Corporation',
        SMODEL        => 'PowerEdge 1800',
        SSN           => '2K1012J',
        BMANUFACTURER => 'Dell Computer Corporation',
        BVERSION      => 'A05',
        BDATE         => '09/21/2005'
    },
    'dmidecode.rhel.2.1' => {
        ASSETTAG      => 'N/A',
        SMANUFACTURER => 'IBM',
        SMODEL        => '-[84803AX]-',
        SSN           => 'KBKGW40',
        BMANUFACTURER => 'IBM',
        BVERSION      => '-[JPE130AUS-1.30]-'
    },
    'dmidecode.rhel.3.4' => {
        ASSETTAG      => '12345678901234567890123456789012',
        SMANUFACTURER => 'IBM',
        SMODEL        => 'IBM eServer x226-[8488PCR]-',
        SSN           => 'KDXPC16',
        BMANUFACTURER => 'IBM',
        BVERSION      => 'IBM BIOS Version 1.57-[PME157AUS-1.57]-',
        BDATE         => '08/25/2005'
    },
    'dmidecode.rhel.4.3' => {
        SMANUFACTURER => 'IBM',
        SMODEL        => '-[86494jg]-',
        SSN           => 'KDMAH1Y',
        BMANUFACTURER => 'IBM',
        BVERSION      => '-[OQE115A]-',
        BDATE         => '03/14/2006'
    },
    'dmidecode.rhel.4.6' => {
        SMANUFACTURER => 'HP',
        SMODEL        => 'ProLiant ML350 G5',
        SSN           => 'GB8814HE7S',
        BMANUFACTURER => 'HP',
        BVERSION      => 'D21',
        BDATE         => '01/24/2008'
    },
    'dmidecode-2.10-windows' => {
        SMANUFACTURER => 'TOSHIBA',
        SMODEL        => 'Satellite 2410',
        SSN           => 'X2735244G',
        BMANUFACTURER => 'TOSHIBA',
        BVERSION      => 'Version 1.10',
        BDATE         => '08/13/2002',
        ASSETTAG      => '0000000000',
    }
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/$test";
    my ($bios, $hardware) = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios::parseDmidecode($file, '<');
    is_deeply($bios, $tests{$test}, $test);
}
