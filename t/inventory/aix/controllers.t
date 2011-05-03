#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers;

my %tests = (
    sample1 => [
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
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test.adapter";
    my @controllers = FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers::_getControllers(file => $file);
    is_deeply(\@controllers, $tests{$test}, "controllers: $test");
}
