#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;
use English;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::MacOS::Storages;

my %tests = (
    '10.4-powerpc' => [
        {
            NAME         => 'HL-DT-ST DVD-RW GWA-4165B',
            FIRMWARE     => 'C006',
            TYPE         => 'ATA',
            SERIAL       => 'B6FD7234EC63',
            DISKSIZE     => undef,
            MANUFACTURER => 'HL-DT-ST DVD-RW GWA-4165B',
            MODEL        => '',
            DESCRIPTION  => 'CD-ROM Drive'
        }
    ],
    '10.5-powerpc' => [
        {
            NAME         => 'HL-DT-ST DVD-RW GWA-4165B',
            FIRMWARE     => 'C006',
            TYPE         => 'ATA',
            SERIAL       => 'B6FD7234EC63',
            DISKSIZE     => undef,
            MANUFACTURER => 'HL-DT-ST DVD-RW GWA-4165B',
            MODEL        => '',
            DESCRIPTION  => 'CD-ROM Drive'
        },
        {
            NAME         => 'Flash Disk',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '110074973765',
            DISKSIZE     => 1960000,
            MANUFACTURER => 'Flash Disk',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        },
        {
            NAME         => 'DataTraveler 2.0',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '89980116200801151425097A',
            DISKSIZE     => 3760000,
            MANUFACTURER => 'DataTraveler 2.0',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        }
    ],
    '10.6-intel' => [
        {
            NAME         => 'MATSHITADVD-R   UJ-875',
            FIRMWARE     => 'DB09',
            TYPE         => 'ATA',
            SERIAL       => '            fG424F9E',
            DISKSIZE     => undef,
            MANUFACTURER => 'Matshita',
            MODEL        => 'DVD-R   UJ-875',
            DESCRIPTION  => 'CD-ROM Drive'
        },
        {
            NAME         => 'Flash Disk      ',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '110074973765',
            DISKSIZE     => 2110000,
            MANUFACTURER => 'Flash Disk      ',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        }
    ],
    '10.6.6-intel' => [
        {
            NAME         => 'MATSHITACD-RW  CW-8221',
            FIRMWARE     => 'GA0J',
            TYPE         => 'ATA',
            SERIAL       => undef,
            DISKSIZE     => undef,
            MANUFACTURER => 'Matshita',
            MODEL        => 'CD-RW  CW-8221',
            DESCRIPTION  => 'CD-ROM Drive'
        }
    ],
    'fiberchannel' => [
        {
            NAME         => 'SCSI Logical Unit @ 0',
            FIRMWARE     => 'R001',
            TYPE         => 'Fibre Channel',
            SERIAL       => undef,
            DISKSIZE     => 20010000,
            MANUFACTURER => 'SCSI Logical Unit @ 0',
            MODEL        => 'Production Backu',
            DESCRIPTION  => 'Disk drive'
        },
        {
            NAME         => 'SCSI Logical Unit @ 0',
            FIRMWARE     => '1.0.',
            TYPE         => 'Fibre Channel',
            SERIAL       => undef,
            DISKSIZE     => 20010000,
            MANUFACTURER => 'SCSI Logical Unit @ 0',
            MODEL        => 'UltraStorRS16FS',
            DESCRIPTION  => 'Disk drive'
        }
    ]
);

my %testsSerialATA = (
    'SPSerialATADataType.xml' => [
        {
            NAME         => 'disk0',
            MANUFACTURER => 'Western Digital',
            INTERFACE    => 'SERIAL-ATA',
            SERIAL       => 'WD-WCARY1264478',
            MODEL        => 'WDC WD2500AAJS-40VWA1',
            FIRMWARE     => '58.01D02',
            DISKSIZE     => FusionInventory::Agent::Task::Inventory::MacOS::Storages::_fromBytesToMegaBytes(250059350016),
            TYPE         => 'Disk drive',
            DESCRIPTION  => 'WDC WD2500AAJS-40VWA1'
        }
    ],
    'SPSerialATADataType2.xml' => [
        {
            NAME         => 'disk0',
            MANUFACTURER => 'Apple',
            INTERFACE    => 'SERIAL-ATA',
            SERIAL       => '1435NL400611',
            MODEL        => 'SSD SD0128F',
            FIRMWARE     => 'A222821',
            DISKSIZE     => FusionInventory::Agent::Task::Inventory::MacOS::Storages::_fromBytesToMegaBytes(121332826112),
            TYPE         => 'Disk drive',
            DESCRIPTION  => 'APPLE SSD SD0128F'
        }
    ]
);

my %testsDiscBurning = (
    'SPDiscBurningDataType.xml' => [
        {
            NAME         => 'OPTIARC DVD RW AD-5630A',
            MANUFACTURER => 'Sony',
            INTERFACE    => 'ATAPI',
            MODEL        => 'OPTIARC DVD RW AD-5630A',
            FIRMWARE     => '1AHN',
            TYPE         => 'Disk burning'
        }
    ],
    'SPDiscBurningDataType2.xml' => []
);

my %testsCardReader = (
    'SPCardReaderDataType.xml' => [
        {
            NAME         => 'spcardreader',
            SERIAL       => '000000000820',
            MODEL        => 'spcardreader',
            FIRMWARE     => '3.00',
            MANUFACTURER => '0x05ac',
            TYPE         => 'Card reader',
            DESCRIPTION  => 'spcardreader'
        }
    ],
    'SPCardReaderDataType_with_inserted_card.xml' => [
        {
            NAME         => 'spcardreader',
            DESCRIPTION  => 'spcardreader',
            SERIAL       => '000000000820',
            MODEL        => 'spcardreader',
            FIRMWARE     => '3.00',
            MANUFACTURER => '0x05ac',
            TYPE         => 'Card reader'
        },
        {
            NAME         => 'disk2',
            DESCRIPTION  => 'SDHC Card',
            DISKSIZE     => sprintf("%d", 15931539456 / 1024 / 1024),
            TYPE         => 'SD Card'
        }
    ]
);

my %testsUSBStorage = (
    'SPUSBDataType.xml' => [
        {
            NAME         => 'disk1',
            SERIAL       => '20150123045944',
            MODEL        => 'External USB 3.0',
            FIRMWARE     => '1.07',
            MANUFACTURER => 'Toshiba',
            DESCRIPTION  => 'External USB 3.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => FusionInventory::Agent::Task::Inventory::MacOS::Storages::_fromBytesToMegaBytes(500107859968)
        }
    ],
    'SPUSBDataType_without_inserted_dvd.xml' => [
        {
            NAME         => 'Optical USB 2.0',
            SERIAL       => 'DEF109C77CF6',
            MODEL        => 'Optical USB 2.0',
            FIRMWARE     => '0.01',
            MANUFACTURER => 'Iomega',
            DESCRIPTION  => 'Optical USB 2.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => ''
        }
    ],
    'SPUSBDataType_with_inserted_dvd.xml' => [
        {
            NAME         => 'disk3',
            SERIAL       => 'DEF109C77CF6',
            MODEL        => 'Optical USB 2.0',
            FIRMWARE     => '0.01',
            MANUFACTURER => 'Iomega',
            DESCRIPTION  => 'Optical USB 2.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 392647584 / 1024 / 1024)
        }
    ],
    'SPUSBDataType2.xml' => [
        {
            NAME         => 'disk1',
            SERIAL       => 'AASOP1QMSZ0XG051',
            MODEL        => 'JumpDrive',
            FIRMWARE     => '11.00',
            MANUFACTURER => 'Lexar',
            DESCRIPTION  => 'JumpDrive',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 7.34 * 1024)
        },
        {
            NAME         => 'disk3',
            SERIAL       => '20150123045944',
            MODEL        => 'External USB 3.0',
            FIRMWARE     => '1.07',
            MANUFACTURER => 'Toshiba',
            DESCRIPTION  => 'External USB 3.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => FusionInventory::Agent::Task::Inventory::MacOS::Storages::_fromGigaBytesToMegaBytes(465.76)
        },
        {
            NAME         => 'disk2',
            SERIAL       => '1311141504461042257807',
            MODEL        => 'UDisk 2.0',
            FIRMWARE     => '1.00',
            MANUFACTURER => 'General',
            DESCRIPTION  => 'UDisk 2.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => FusionInventory::Agent::Task::Inventory::MacOS::Storages::_fromGigaBytesToMegaBytes(1.88)
        }
    ],
    'SPUSBDataType3.xml' => [
        {
            NAME         => 'disk3',
            SERIAL       => '20150123045944',
            MODEL        => 'External USB 3.0',
            FIRMWARE     => '1.07',
            MANUFACTURER => 'Toshiba',
            DESCRIPTION  => 'External USB 3.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 465.76 * 1024)
        },
        {
            NAME         => 'disk1',
            SERIAL       => '1311141504461042257807',
            MODEL        => 'UDisk 2.0',
            FIRMWARE     => '1.00',
            MANUFACTURER => 'General',
            DESCRIPTION  => 'UDisk 2.0',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 1.88 * 1024)
        },
        {
            NAME         => 'disk6',
            SERIAL       => 'AASOP1QMSZ0XG051',
            MODEL        => 'JumpDrive',
            FIRMWARE     => '11.00',
            MANUFACTURER => 'Lexar',
            DESCRIPTION  => 'JumpDrive',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 7.34 * 1024)
        },
        {
            NAME         => 'disk5',
            SERIAL       => '8CA13C74',
            MODEL        => 'Mass Storage',
            FIRMWARE     => '1.03',
            MANUFACTURER => 'Generic',
            DESCRIPTION  => 'Mass Storage',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 3.84 * 1024)
        },
        {
            NAME         => 'disk4',
            SERIAL       => '024279000000034C',
            MODEL        => 'USB Flash Disk',
            FIRMWARE     => '1.00',
            MANUFACTURER => 'General',
            DESCRIPTION  => 'USB Flash Disk',
            TYPE         => 'Disk drive',
            INTERFACE    => 'USB',
            DISKSIZE     => sprintf("%d", 3.73 * 1024)
        }
    ]
);

my %testsFireWireStorage = (
    'SPFireWireDataType.xml' => [
        {
            NAME         => 'disk2',
            DESCRIPTION  => 'Target Disk Mode SBP-LUN',
            DISKSIZE     => sprintf("%d", 298.09 * 1024),
            FIRMWARE     => '',
            INTERFACE    => 'FireWire',
            MANUFACTURER => '',
            MODEL        => '',
            SERIAL       => '',
            TYPE         => 'Disk drive'
        }
    ]
);

plan tests => (2 * scalar (keys %tests))
        + 1
        + scalar (keys %testsSerialATA)
        + scalar (keys %testsDiscBurning)
        + scalar (keys %testsCardReader)
        + scalar (keys %testsUSBStorage)
        + scalar (keys %testsFireWireStorage)
        + 2
;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test";
    my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getStorages(file => $file);
    cmp_deeply(
        [ sort { compare() } @storages ],
        [ sort { compare() } @{$tests{$test}} ],
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'STORAGES', entry => $_)
            foreach @storages;
    } "$test: registering";
}

XML::XPath->require();
my $checkXmlXPath = $EVAL_ERROR ? 0 : 1;
my $nbTests = scalar (keys %testsSerialATA)
    + scalar (keys %testsDiscBurning)
    + scalar (keys %testsCardReader)
    + scalar (keys %testsUSBStorage)
    + scalar (keys %testsFireWireStorage);
SKIP: {
    skip "test only if module XML::XPath available", $nbTests unless $checkXmlXPath;

    foreach my $test (keys %testsSerialATA) {
        my $file = "resources/macos/system_profiler/$test";
        my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getSerialATAStorages(file => $file);
        cmp_deeply(
            [ sort { compare() } @storages ],
            [ sort { compare() } @{$testsSerialATA{$test}} ],
            "testsSerialATA $test: parsing"
        );
    }

    foreach my $test (keys %testsDiscBurning) {
        my $file = "resources/macos/system_profiler/$test";
        my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getDiscBurningStorages(file => $file);
        cmp_deeply(
            [ sort { compare() } @storages ],
            [ sort { compare() } @{$testsDiscBurning{$test}} ],
            "testsDiscBurning $test: parsing"
        );
    }

    foreach my $test (keys %testsCardReader) {
        my $file = "resources/macos/system_profiler/$test";
        my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getCardReaderStorages(file => $file);
        cmp_deeply(
            [ sort { compare() } @storages ],
            [ sort { compare() } @{$testsCardReader{$test}} ],
            "testsDiscBurning $test: parsing"
        );
    }

    foreach my $test (keys %testsUSBStorage) {
        my $file = "resources/macos/system_profiler/$test";
        my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getUSBStorages(file => $file);
        cmp_deeply(
            [ sort { compare() } @storages ],
            [ sort { compare() } @{$testsUSBStorage{$test}} ],
            "testsUSBStorage $test: parsing"
        );
    }

    foreach my $test (keys %testsFireWireStorage) {
        my $file = "resources/macos/system_profiler/$test";
        my @storages = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_getFireWireStorages(file => $file);
        cmp_deeply(
            [ sort { compare() } @storages ],
            [ sort { compare() } @{$testsFireWireStorage{$test}} ],
            "testsFireWireStorage $test: parsing"
        );
    }
}

my $cleanedSizeStr = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_cleanSizeString('297,29 GB');
ok (defined $cleanedSizeStr && $cleanedSizeStr eq '297.29');
$cleanedSizeStr = FusionInventory::Agent::Task::Inventory::MacOS::Storages::_cleanSizeString('2456 MB');
ok (defined $cleanedSizeStr && $cleanedSizeStr eq '2456');


sub compare {
    return
        $a->{NAME}  cmp $b->{NAME} ||
        $a->{MODEL} cmp $b->{MODEL};
}
