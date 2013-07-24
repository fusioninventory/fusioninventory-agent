#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::HPUX::Slots;

my %tests = (
    'hpux2-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
        }
    ],
    'hpux2-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
        }
    ],
    'hpux1-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
        }
    ],
    'hpux1-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @slots = FusionInventory::Agent::Task::Inventory::HPUX::Slots::_getSlots(file => $file);
    cmp_deeply(\@slots, $tests{$test}, "$test ioscan parsing");
}
