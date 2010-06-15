#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;
use Test::More;
use FindBin;

my %tests = (
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

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/udev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::parseUdev($file, 'sda');
    is_deeply($tests{$test}, $result, $test);
}
