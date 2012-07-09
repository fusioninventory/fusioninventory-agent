#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Megaraid;
use Test::More;

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
    is_deeply(\@disks, $tests{$test}, $test);
}
