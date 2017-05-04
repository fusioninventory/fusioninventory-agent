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

my $tests_sysctl = {
    pfsense1 => {
        'content'  => [
            {
                DESCRIPTION  => '<QEMU HARDDISK 1.0> ATA-7 device',
                NAME         => 'ada0',
                TYPE         => 'disk',
                SERIALNUMBER => 'QM00001',
                DISKSIZE => 4294967296,
                MODEL => 'QEMU HARDDISK 1.0'
            },
            {
                DESCRIPTION  => '<QEMU QEMU DVD-ROM 1.0> Removable CD-ROM SCSI device',
                NAME         => 'cd0',
                TYPE         => 'cdrom',
                SERIALNUMBER => 'QM00003',
                DISKSIZE => 0,
                MODEL => 'QEMU QEMU DVD-ROM 1.0'
            }
        ],
        dmesgFile  => 'dmesg',
        sysctlFile => 'kern.geom.confxml'
    }
};

plan tests =>
    (2 * scalar keys %tests_fstab)   +
    (2 * scalar keys %tests_mfiutil) +
    scalar (keys %$tests_sysctl) +
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

my $pathToBSDFiles = 'resources/bsd/storages/';
for my $test (keys %$tests_sysctl) {
    my @results = FusionInventory::Agent::Task::Inventory::BSD::Storages::_retrieveStoragesFromSysCtl(
        dmesgFile => $pathToBSDFiles . $tests_sysctl->{$test}->{dmesgFile},
        sysctlFile => $pathToBSDFiles . $tests_sysctl->{$test}->{sysctlFile}
    );
    @results = sort { $a->{NAME} cmp $b->{NAME} } @results;
    my @expected = sort { $a->{NAME} cmp $b->{NAME} } @{$tests_sysctl->{$test}->{content}};
    cmp_deeply(
        \@results,
        \@expected,
        $test
    );
}
