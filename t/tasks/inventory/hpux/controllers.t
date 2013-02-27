#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::HPUX::Controllers;

my %tests = (
    'hpux2-ext_bus' => [
        {
            TYPE => 'IDE Primary Channel',
        },
        {
            TYPE => 'IDE Secondary Channel',
        },
        {
            TYPE => 'SCSI Ultra320',
        },
        {
            TYPE => 'SCSI Ultra320',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'PCI-X SmartArray 6402 RAID Controller',
        }
    ],
    'hpux2-fc' => [
        {
            TYPE => 'HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 1)',
        },
        {
            TYPE => 'HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 2)',
        }

    ],
    'hpux1-ext_bus' => [
         {
            TYPE => 'IDE Primary Channel',
        },
        {
            TYPE => 'IDE Secondary Channel',
        },
        {
            TYPE => 'SCSI Ultra320',
        },
        {
            TYPE => 'SCSI Ultra320',
        },
        {
            TYPE => 'SCSI Ultra320 A6961-60011',
        },
        {
            TYPE => 'SCSI Ultra320 A6961-60011',
        },
        {
            TYPE => 'PCI-X SmartArray 6402 RAID Controller',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'FCP Array Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'FCP Device Interface',
        },
        {
            TYPE => 'SCSI Ultra320 A6961-60011',
        },
        {
            TYPE => 'SCSI Ultra320 A6961-60011',
        }
    ],
    'hpux1-fc' => [
        {
            TYPE => 'HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 1)',
        },
        {
            TYPE => 'HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 2)',
        }

    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @controllers = FusionInventory::Agent::Task::Inventory::HPUX::Controllers::_getControllers(file => $file);
    cmp_deeply(\@controllers, $tests{$test}, "$test ioscan parsing");
}
