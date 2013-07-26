#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::BSD::Storages;
use FusionInventory::Agent::Task::Inventory::BSD::Storages::Megaraid;

my %tests_fstab = (
    'freebsd-1' => [
        {
            'DESCRIPTION' => 'da0s1b'
        },
        {
            'DESCRIPTION' => 'da0s1a'
        },
        {
            'DESCRIPTION' => 'da0s1d'
        },
        {
            'DESCRIPTION' => 'acd0'
        }
    ]
);

my %tests_mfiutil = (
    'mfiutil' => [
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZJGW',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZA3R',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZWGQ',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZWCE',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZKED',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        },
        {
            'NAME' => 'SEAGATE ST3600057SS',
            'DISKSIZE' => '571392',
            'SERIALNUMBER' => '3SL1ZYJE',
            'DESCRIPTION' => 'SAS',
            'TYPE' => 'disk'
        }
    ]
);

plan tests =>
    (2 * scalar keys %tests_fstab)   +
    (2 * scalar keys %tests_mfiutil) + 
    1;

my $inventory = FusionInventory::Agent::Inventory->new();

foreach my $test (keys %tests_fstab) {
    my $file = "resources/bsd/fstab/$test";
    my @results = FusionInventory::Agent::Task::Inventory::BSD::Storages::_getDevicesFromFstab(file => $file);
    cmp_deeply(\@results, $tests_fstab{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'STORAGES', entry => $_)
            foreach @results;
    } "$test: registering";
}

foreach my $test (keys %tests_mfiutil) {
    my $file = "resources/bsd/storages/$test";
    my @results = FusionInventory::Agent::Task::Inventory::BSD::Storages::Megaraid::_parseMfiutil(file => $file);
    cmp_deeply(\@results, $tests_mfiutil{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'STORAGES', entry => $_)
            foreach @results;
    } "$test: registering";
}
