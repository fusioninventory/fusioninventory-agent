#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots;

my %tests = (
    'hpux2-ioa' => [
        {
            NAME        => 'ioa',
            DESIGNATION => 'BUS_NEXUS System Bus Adapter (1229)',
            STATUS      => 'OK',
            DESCRIPTION => '0'
        }
    ],
    'hpux2-ba' => [
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/0'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/1'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/2'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/3'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS PCItoPCI Bridge',
            STATUS      => 'OK',
            DESCRIPTION => '0/3/1/0'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/4'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/5'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/6'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Core I/O Adapter',
            STATUS      => 'OK',
            DESCRIPTION => '250'
        }
    ],
    'hpux1-ioa' => [
        {
            NAME        => 'ioa',
            DESIGNATION => 'BUS_NEXUS System Bus Adapter (1229)',
            STATUS      => 'OK',
            DESCRIPTION => '0'
        }
    ],
    'hpux1-ba' => [
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/0'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/1'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/2'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/3'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS PCItoPCI Bridge',
            STATUS      => 'OK',
            DESCRIPTION => '0/3/1/0'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/4'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/5'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
            DESCRIPTION => '0/6'
        },
        {
            NAME        => 'ba',
            DESIGNATION => 'BUS_NEXUS Core I/O Adapter',
            STATUS      => 'OK',
            DESCRIPTION => '250'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @slots = FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots::_getSlots(file => $file);
    is_deeply(\@slots, $tests{$test}, "$test ioscan parsing");
}
