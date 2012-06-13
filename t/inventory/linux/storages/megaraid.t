#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Megaraid;
use Test::More;

my %tests = (
    sample => [ 
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
          'TYPE' => 'disk'
        },
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
          'TYPE' => 'disk'
        },
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
          'TYPE' => 'disk'
        },
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
          'TYPE' => 'disk'
        },
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
          'TYPE' => 'disk'
        },
        {
          'NAME' => 'SEAGATE ST3600057SS',
          'DISKSIZE' => '571392',
          'DESCRIPTION' => 'SAS',
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
