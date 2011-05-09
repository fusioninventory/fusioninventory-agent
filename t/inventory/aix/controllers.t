#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers;

my %tests = (
    'aix-5.3' => [
        {
            NAME => 'ent0',
        },
        {
            NAME => 'ent1',
        },
        {
            NAME => 'ide0',
        },
        {
            NAME => 'lai0',
        },
        {
            NAME => 'sa0',
        },
        {
            NAME => 'sa1',
        },
        {
            NAME => 'sisscsia0',
        },
        {
            NAME => 'usbhc0',
        },
        {
            NAME => 'usbhc1',
        },
        {
            NAME  => 'vsa0',
        },
        {
            NAME => 'vsa1',
        },
        {
            NAME => 'vsa2',
        }
    ],
    'aix-6.1' => [
        {
            NAME => 'ent0'
        },
        {
            NAME => 'ent1'
        },
        {
            NAME => 'ent2'
        },
        {
            NAME => 'fcs0'
        },
        {
            NAME => 'fcs1'
        },
        {
            NAME => 'fcs2'
        },
        {
            NAME => 'fcs3'
        },
        {
            NAME => 'fcs4'
        },
        {
            NAME => 'lhea0'
        },
        {
            NAME => 'vsa0'
        },
        {
            NAME => 'vscsi0'
        },
        {
            NAME => 'vscsi1'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test-adapter";
    my @controllers = FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers::_getControllers(file => $file);
    is_deeply(\@controllers, $tests{$test}, "controllers: $test");
}
