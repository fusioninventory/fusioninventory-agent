#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::HPUX::Slots;

my %tests = (
    'hpux2-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
            STATUS      => 'OK',
        }
    ],
    'hpux2-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
            STATUS      => 'OK',
        }
    ],
    'hpux1-ioa' => [
        {
            DESIGNATION => 'System Bus Adapter (1229)',
            STATUS      => 'OK',
        }
    ],
    'hpux1-ba' => [
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'PCItoPCI Bridge',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Local PCI-X Bus Adapter (122e)',
            STATUS      => 'OK',
        },
        {
            DESIGNATION => 'Core I/O Adapter',
            STATUS      => 'OK',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/hpux/ioscan/$test";
    my @slots = FusionInventory::Agent::Task::Inventory::Input::HPUX::Slots::_getSlots(file => $file);
    cmp_deeply(\@slots, $tests{$test}, "$test ioscan parsing");
}
