#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use Test::More;
use FindBin;
use File::Basename;

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

	},
        'dmidecode.esx2.5' => {
          'MSN' => 'None',
          'SMODEL' => 'VMware Virtual Platform',
          'SMANUFACTURER' => 'VMware, Inc.',
          'SSN' => 'VMware-56 4d db dd 11 e3 8d 66-84 9e 15 8e 49 23 7c 97',
          'ASSETTAG' => 'No Asset Tag',
          'BVERSION' => '6.00',
          'BMANUFACTURER' => 'Phoenix Technologies LTD'
        },
        'hp-proLiant-DL120-G6' => {
          'MMANUFACTURER' => 'Wistron Corporation',
          'SKUNUMBER' => '000000-000',
          'SSN' => 'XXXXXXXXXX',
          'ASSETTAG' => 'No Asset Tag',
          'BMANUFACTURER' => 'HP',
          'MSN' => '0123456789',
          'SMANUFACTURER' => 'HP',
          'SMODEL' => 'ProLiant DL120 G6',
          'MMODEL' => 'ProLiant DL120 G6',
          'BDATE' => '01/26/2010',
          'BVERSION' => 'O26'
        },
        'dmidecode-S5000VSA' => {
          'MMANUFACTURER' => 'Intel',
          'SKUNUMBER' => 'Not Specified',
          'SSN' => '.........',
          'ASSETTAG' => '',
          'BMANUFACTURER' => 'Intel Corporation',
          'MSN' => 'QSSA64700622',
          'SMANUFACTURER' => 'Intel',
          'SMODEL' => 'MP Server',
          'MMODEL' => 'S5000VSA',
          'BDATE' => '10/12/2006',
          'BVERSION' => 'S5000.86B.04.00.0066.101220061333'
        },
        'dmidecode-S3000AHLX' => {
          'MMANUFACTURER' => 'Intel Corporation',
          'SKUNUMBER' => 'Not Specified',
          'SSN' => 'Not Specified',
          'ASSETTAG' => '',
          'BMANUFACTURER' => 'Intel Corporation',
          'MSN' => 'AZAX63801455',
          'SMANUFACTURER' => 'Not Specified',
          'SMODEL' => 'Not Specified',
          'MMODEL' => 'S3000AHLX',
          'BDATE' => '09/01/2006',
          'BVERSION' => 'S3000.86B.02.00.0031.090120061242'
        },
        'dmidecode-openbsd-4.5' => {
          'MMANUFACTURER' => 'Dell Computer Corporation',
          'SSN' => '4V2VW0J',
          'ASSETTAG' => '',
          'BMANUFACTURER' => 'Dell Computer Corporation',
          'MSN' => '..TW128003952967.',
          'SMANUFACTURER' => 'Dell Computer Corporation',
          'SMODEL' => 'PowerEdge 1600SC          ',
          'BDATE' => '06/24/2003',
          'MMODEL' => '0Y1861',
          'BVERSION' => 'A08'
        },
        'dmidecode-hp-dl180' => {
          'SMODEL' => 'ProLiant DL180 G6 ',
          'SMANUFACTURER' => 'HP',
          'SKUNUMBER' => '470065-124',
          'SSN' => 'CZJ02901TG',
          'BDATE' => '05/19/2010',
          'BVERSION' => 'O20',
          'BMANUFACTURER' => 'HP'
        },
        'dmidecode-2.10-linux' => {
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
        },
        'dmidecode-hyperV' => {
          'MMANUFACTURER' => 'Microsoft Corporation',
          'SSN' => '2349-2347-2234-2340-2341-3240-48',
          'ASSETTAG' => '4568-2345-6432-9324-3433-2346-47',
          'BMANUFACTURER' => 'American Megatrends Inc.',
          'MSN' => '2349-2347-2234-2340-2341-3240-48',
          'SMANUFACTURER' => 'Microsoft Corporation',
          'SMODEL' => 'Virtual Machine',
          'BDATE' => '03/19/2009',
          'MMODEL' => 'Virtual Machine',
          'BVERSION' => '090004'
        }
);

my @dmifiles = glob("$FindBin::Bin/../resources/dmidecode-*");
plan tests => int @dmifiles;
use Data::Dumper;
foreach my $file (@dmifiles) {
    my $test = basename ($file);
    my ($bios, $hardware) = FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios::parseDmidecode($file, '<');
    is_deeply($bios, $tests{$test}, $test) or print Dumper($bios);
}
