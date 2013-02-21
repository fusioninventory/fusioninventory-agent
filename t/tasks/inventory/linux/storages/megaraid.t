#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Megaraid;

my %tests = (
    sample => [
        {
            'NAME' => 'a0e32s0',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'a0e32s1',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'a0e32s2',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'a0e32s3',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'a0e32s4',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'a0e32s5',
            'DISKSIZE' => '571392',
            'DESCRIPTION' => 'SAS',
            'MODEL' => 'ST3600057SS',
            'MANUFACTURER' => 'SEAGATE',
            'TYPE' => 'disk'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/linux/megasasctl/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Megaraid::_parseMegasasctl(
        file       => $file
    );
    cmp_deeply(\@disks, $tests{$test}, $test);
}
