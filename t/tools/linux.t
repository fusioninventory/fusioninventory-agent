#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Logger;
use Test::More;

my %udev_tests = (
    'ssd' => {
        NAME         => 'sda',
        FIRMWARE     => 'VBM24DQ1',
        SCSI_UNID    => '0',
        SERIALNUMBER => 'DFW1W11002SE002B3117',
        TYPE         => 'disk',
        SCSI_CHID    => '0',
        SCSI_COID    => '0',
        SCSI_LUN     => '0',
        DESCRIPTION  => 'ata',
        MODEL        => 'SAMSUNG_SSD_PM800_TM_128GB'
    },
);

plan tests => scalar keys %udev_tests;

foreach my $test (keys %udev_tests) {
    my $file = "resources/udev/$test";
    my $result = FusionInventory::Agent::Tools::Linux::parseUdevEntry($file, 'sda');
    is_deeply($result, $udev_tests{$test}, $test);
}
