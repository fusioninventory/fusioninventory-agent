#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use Test::More;
use FindBin;

my %tests = (
    'dmidecode-freebsd-6.2' => {
        SystemManufacturer => ' ',
        SystemModel        => ' ',
        SystemSerial       => ' ',
    },
    'dmidecode-linux-2.6' => {
        AssetTag           => '',
        SystemManufacturer => 'Dell Inc.',
        SystemModel        => 'Latitude D610',
        SystemSerial       => 'D8XD62J',
        BiosManufacturer   => 'Dell Inc.',
        BiosVersion        => 'A06',
        BiosDate           => '10/02/2005'
    },
    'dmidecode-openbsd-3.7' => {
        SystemManufacturer => 'VIA Technologies, Inc.',
        SystemModel        => 'VT82C691',
        SystemSerial       => '52-06-00-00-FF-F9-83-01',
        BiosManufacturer   => 'Award Software International, Inc.',
        BiosVersion        => '4.51 PG',
        BiosDate           => '02/11/99'
    },
    'dmidecode-openbsd-3.8' => {
        AssetTag           => '',
        SystemManufacturer => 'Dell Computer Corporation',
        SystemModel        => 'PowerEdge 1800',
        SystemSerial       => '2K1012J',
        BiosManufacturer   => 'Dell Computer Corporation',
        BiosVersion        => 'A05',
        BiosDate           => '09/21/2005'
    },
    'dmidecode.rhel.2.1' => {
        AssetTag           => 'N/A',
        SystemManufacturer => 'IBM',
        SystemModel        => '-[84803AX]-',
        SystemSerial       => 'KBKGW40',
        BiosManufacturer   => 'IBM',
        BiosVersion        => '-[JPE130AUS-1.30]-'
    },
    'dmidecode.rhel.3.4' => {
        AssetTag           => '12345678901234567890123456789012',
        SystemManufacturer => 'IBM',
        SystemModel        => 'IBM eServer x226-[8488PCR]-',
        SystemSerial       => 'KDXPC16',
        BiosManufacturer   => 'IBM',
        BiosVersion        => 'IBM BIOS Version 1.57-[PME157AUS-1.57]-',
        BiosDate           => '08/25/2005'
    },
    'dmidecode.rhel.4.3' => {
        SystemManufacturer => 'IBM',
        SystemModel        => '-[86494jg]-',
        SystemSerial       => 'KDMAH1Y',
        BiosManufacturer   => 'IBM',
        BiosVersion        => '-[OQE115A]-',
        BiosDate           => '03/14/2006'
    },
    'dmidecode.rhel.4.6' => {
        SystemManufacturer => 'HP',
        SystemModel        => 'ProLiant ML350 G5',
        SystemSerial       => 'GB8814HE7S',
        BiosManufacturer   => 'HP',
        BiosVersion        => 'D21',
        BiosDate           => '01/24/2008'
    },
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/$test";
    my %result = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios::parseDmidecode($file, '<');
    is_deeply($tests{$test}, \%result, $test);
}
