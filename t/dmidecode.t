#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use Test::More;
use FindBin;

my %tests = (
	'dmidecode-freebsd-6.2' => {
	'MSN' => '',
	'MMANUFACTURER' => '',
	'SMODEL' => '',
	'SMANUFACTURER' => '',
	'MMODEL' => 'CN700-8237R',
	'SSN' => ''
	},
	'dmidecode-linux-2.6' => {
	'MMANUFACTURER' => 'Dell Inc.',
	'SSN' => 'D8XD62J',
	'ASSETTAG' => '',
	'BMANUFACTURER' => 'Dell Inc.',
	'MSN' => '.D8XD62J.CN4864363E7491.',
	'SMANUFACTURER' => 'Dell Inc.',
	'SMODEL' => 'Latitude D610                  ',
	'BDATE' => '10/02/2005',
	'MMODEL' => '0XD762',
	'BVERSION' => 'A06'
	},
	'dmidecode-openbsd-3.7' => {
	    'MMANUFACTURER' => 'Tekram Technology Co., Ltd.',
	    'SMODEL' => 'VT82C691',
	    'SMANUFACTURER' => 'VIA Technologies, Inc.',
	    'MMODEL' => 'P6PROA5',
	    'BDATE' => '02/11/99',
	    'BVERSION' => '4.51 PG',
	    'BMANUFACTURER' => 'Award Software International, Inc.'

	},
	'dmidecode-openbsd-3.8' => {
	    'MMANUFACTURER' => 'Dell Computer Corporation',
	    'SSN' => '2K1012J',
	    'ASSETTAG' => '',
	    'BMANUFACTURER' => 'Dell Computer Corporation',
	    'MSN' => '..CN717035A80217.',
	    'SMANUFACTURER' => 'Dell Computer Corporation',
	    'SMODEL' => 'PowerEdge 1800',
	    'BDATE' => '09/21/2005',
	    'MMODEL' => '0P8611',
	    'BVERSION' => 'A05'

	},
	'dmidecode.rhel.2.1' => {
	    'MSN' => 'NA60B7Y0S3Q',
	    'SMODEL' => '-[84803AX]-',
	    'SMANUFACTURER' => 'IBM',
	    'SSN' => 'KBKGW40',
	    'ASSETTAG' => 'N/A',
	    'BVERSION' => '-[JPE130AUS-1.30]-',
	    'BMANUFACTURER' => 'IBM'
	},
	'dmidecode.rhel.3.4' => {
	    'MMANUFACTURER' => 'IBM',
	    'SSN' => 'KDXPC16',
	    'ASSETTAG' => '12345678901234567890123456789012',
	    'BMANUFACTURER' => 'IBM',
	    'MSN' => '#A123456789',
	    'SMANUFACTURER' => 'IBM',
	    'SMODEL' => 'IBM eServer x226-[8488PCR]-',
	    'BDATE' => '08/25/2005',
	    'MMODEL' => 'MSI-9151 Boards',
	    'BVERSION' => 'IBM BIOS Version 1.57-[PME157AUS-1.57]-'

	},
	'dmidecode.rhel.4.3' => {
	    'MMANUFACTURER' => 'IBM',
	    'SSN' => 'KDMAH1Y',
	    'BMANUFACTURER' => 'IBM',
	    'MSN' => '48Z1LX',
	    'SMANUFACTURER' => 'IBM',
	    'SMODEL' => '-[86494jg]-',
	    'BDATE' => '03/14/2006',
	    'MMODEL' => 'MS-9121',
	    'BVERSION' => '-[OQE115A]-'

	},
	'dmidecode.rhel.4.6' => {
	    'SMODEL' => 'ProLiant ML350 G5',
	    'SMANUFACTURER' => 'HP',
	    'SSN' => 'GB8814HE7S     ',
	    'BDATE' => '01/24/2008',
	    'BVERSION' => 'D21',
	    'BMANUFACTURER' => 'HP'

	},
	'dmidecode-2.10-windows' => {
	    'MMANUFACTURER' => 'TOSHIBA',
	    'SSN' => 'X2735244G',
	    'ASSETTAG' => '0000000000',
	    'BMANUFACTURER' => 'TOSHIBA',
	    'MSN' => '$$T02XB1K9',
	    'SMANUFACTURER' => 'TOSHIBA',
	    'SMODEL' => 'Satellite 2410',
	    'BDATE' => '08/13/2002',
	    'MMODEL' => 'Portable PC',
	    'BVERSION' => 'Version 1.10'

	},
	'dmidecode-linux-1' => {
	    'MMANUFACTURER' => 'ASUSTeK Computer INC.',
	    'SKUNUMBER' => 'To Be Filled By O.E.M.',
	    'SSN' => 'System Serial Number',
	    'ASSETTAG' => 'Asset-1234567890',
	    'BMANUFACTURER' => 'American Megatrends Inc.',
	    'MSN' => 'MS1C93BB0H00980',
	    'SMANUFACTURER' => 'System manufacturer',
	    'SMODEL' => 'System Product Name',
	    'MMODEL' => 'P5Q',
	    'BDATE' => '04/07/2009',
	    'BVERSION' => '2102'

	}
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/$test";
    my ($bios, $hardware) = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios::parseDmidecode($file, '<');
    is_deeply($bios, $tests{$test}, $test);
}
