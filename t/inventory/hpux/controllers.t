#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::HPUX::Controllers;

my %tests = (
    'hpux2-ext_bus' => [
        {
            NAME         => '0/0/2/0.0',
            MANUFACTURER => 'INTERFACE IDE Primary Channel',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/0/2/0.1',
            MANUFACTURER => 'INTERFACE IDE Secondary Channel',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/1/1/0',
            MANUFACTURER => 'INTERFACE SCSI Ultra320',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/1/1/1',
            MANUFACTURER => 'INTERFACE SCSI Ultra320',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/0.1.4.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/0.1.4.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/0.1.5.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/0.1.5.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/1.1.4.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/1.1.4.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/1.1.5.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/1.1.5.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/3/1/0/4/0',
            MANUFACTURER => 'INTERFACE PCI-X SmartArray 6402 RAID Controller',
            TYPE         => 'ext_bus'
        }
    ],
    'hpux2-fc' => [
        {
            NAME         => '0/2/1/0',
            MANUFACTURER => 'INTERFACE HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 1)',
            TYPE         => 'fc'
        },
        {
            NAME         => '0/2/1/1',
            MANUFACTURER => 'INTERFACE HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 2)',
            TYPE         => 'fc'
        }

    ],
    'hpux1-ext_bus' => [
         {
            NAME         => '0/0/2/0.0',
            MANUFACTURER => 'INTERFACE IDE Primary Channel',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/0/2/0.1',
            MANUFACTURER => 'INTERFACE IDE Secondary Channel',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/1/1/0',
            MANUFACTURER => 'INTERFACE SCSI Ultra320',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/1/1/1',
            MANUFACTURER => 'INTERFACE SCSI Ultra320',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/0',
            MANUFACTURER => 'INTERFACE SCSI Ultra320 A6961-60011',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/2/1/1',
            MANUFACTURER => 'INTERFACE SCSI Ultra320 A6961-60011',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/3/1/0/4/0',
            MANUFACTURER => 'INTERFACE PCI-X SmartArray 6402 RAID Controller',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/4/1/0.1.0.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/4/1/0.1.0.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/4/1/0.1.1.0.0',
            MANUFACTURER => 'INTERFACE FCP Array Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/4/1/0.1.1.255.0',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/4/1/1.2.0.255.14',
            MANUFACTURER => 'INTERFACE FCP Device Interface',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/5/1/0',
            MANUFACTURER => 'INTERFACE SCSI Ultra320 A6961-60011',
            TYPE         => 'ext_bus'
        },
        {
            NAME         => '0/5/1/1',
            MANUFACTURER => 'INTERFACE SCSI Ultra320 A6961-60011',
            TYPE         => 'ext_bus'
        }
    ],
    'hpux1-fc' => [
        {
            NAME         => '0/4/1/0',
            MANUFACTURER => 'INTERFACE HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 1)',
            TYPE         => 'fc'
        },
        {
            NAME         => '0/4/1/1',
            MANUFACTURER => 'INTERFACE HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 2)',
            TYPE         => 'fc'
        }

    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @controllers = FusionInventory::Agent::Task::Inventory::OS::HPUX::Controllers::_getControllers(file => $file);
    is_deeply(\@controllers, $tests{$test}, "$test ioscan parsing");
}
