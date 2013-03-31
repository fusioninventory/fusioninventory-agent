#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Solaris::Slots;

my %tests = (
    'sample1' => [
        {
            NAME        => 'MB/NET0',
            DESIGNATION => 'network-pciex8086,105e',
            DESCRIPTION => undef
        },
        {
            NAME        => 'MB/NET1',
            DESIGNATION => 'network-pciex8086,105e',
            DESCRIPTION => undef
        },
        {
            NAME        => 'MB/NET2',
            DESIGNATION => 'network-pciex8086,105e',
            DESCRIPTION => undef
        },
            {
            NAME        => 'MB/NET3',
            DESIGNATION => 'network-pciex8086,105e',
            DESCRIPTION => undef
        },
        {
            NAME        => 'MB/SASHBA',
            DESIGNATION => 'scsi-pciex1000,58',
            DESCRIPTION => 'LSI,1068E'
        },
        {
            NAME        => 'MB/RISER0/PCIE0',
            DESIGNATION => 'SUNW,qlc-pciex1077,2432',
            DESCRIPTION => 'QLE2460'
        },
        {
            NAME        => 'MB',
            DESIGNATION => 'usb-pciclass,0c0310',
            DESCRIPTION => undef
        },
        {
            NAME        => 'MB',
            DESIGNATION => 'usb-pciclass,0c0310',
            DESCRIPTION => undef
        },
        {
            NAME        => 'MB',
            DESIGNATION => 'usb-pciclass,0c0320',
            DESCRIPTION => undef
        }
    ],
    'sample2' => [
        {
            DESIGNATION => 'scsi-pci1000,30.1000.10c0.8/disk+',
            DESCRIPTION => 'LSI,1030'
        },
        {
            DESIGNATION => 'scsi-pci1000,30.1000.10c0.8/disk+',
            DESCRIPTION => 'LSI,1030'
        },
        {
            DESIGNATION => 'scsi-pci1000,30.1000.10c0.8/disk+',
            DESCRIPTION => 'LSI,1030'
        },
        {
            DESIGNATION => 'scsi-pci1000,30.1000.10c0.8/disk+',
            DESCRIPTION => 'LSI,1030'
        },
        {
            DESIGNATION => 'SUNW,XVR-100',
            DESCRIPTION => 'SUNW,375-3181'
        },
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/solaris/prtdiag/$test";
    my @slots = FusionInventory::Agent::Task::Inventory::Solaris::Slots::_getSlots(file => $file);
    cmp_deeply(\@slots, $tests{$test}, $test);
}
