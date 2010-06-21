#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;
use Test::More;
use FindBin;

my %hal_tests = (
    'dell-xt2' => [
        {
            NAME         => 'sda',
            FIRMWARE     => 'VBM24DQ1',
            DISKSIZE     => 122104,
            MANUFACTURER => 'ATA',
            MODEL        => 'SAMSUNG SSD PM80',
            SERIALNUMBER => 'SAMSUNG_SSD_PM800_TM_128GB_DFW1W11002SE002B3117',
            TYPE         => 'disk'
        }
    ]
);

my %udev_tests = (
    'ssd' => {
        NAME         => 'sda',
        FIRMWARE     => 'VBM24DQ1',
        SCSI_UNID    => '0',
        SERIALNUMBER => 'DFW1W11002SE002B3117',
        TYPE         => 'disk',
        SCSI_CHID    => '0',
        SCSI_COID    => '0',
        DISKSIZE     => '',
        SCSI_LUN     => '0',
        DESCRIPTION  => 'ata',
        MODEL        => 'SAMSUNG_SSD_PM800_TM_128GB'
    },
);

plan tests => (scalar keys %hal_tests) + (scalar keys %udev_tests);

foreach my $test (keys %hal_tests) {
    my $file = "$FindBin::Bin/../resources/hal/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::parseLshal($file, '<');
    is_deeply($hal_tests{$test}, $results, $test);
}

foreach my $test (keys %udev_tests) {
    my $file = "$FindBin::Bin/../resources/udev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::parseUdev($file, 'sda');
    is_deeply($udev_tests{$test}, $result, $test);
}
