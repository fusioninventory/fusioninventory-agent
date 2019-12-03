#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Linux::Storages::Lsilogic;

my %disk_tests = (
    sample1 => {
        name       => 'foo',
        disks   => [
             {
                DISKSIZE     => '152576',
                NAME         => 'foo',
                FIRMWARE     => 'D',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3160815AS',
                device       => '/dev/sg1',
            },
            {
                DISKSIZE     => '152576',
                NAME         => 'foo',
                FIRMWARE     => 'D',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3160815AS',
                device       => '/dev/sg0',
          }
        ]
    },
    sample2 => {
        name       => 'foo',
        disks      => [
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'Ibm',
                MODEL        => 'CBRCA146C3ETS0',
                device       => '/dev/sg5',
            },
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'Ibm',
                MODEL        => 'CBRCA146C3ETS0',
                device       => '/dev/sg4',
            },
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'B53C',
                MANUFACTURER => 'Ibm',
                MODEL        => 'ST9146803SS',
                device       => '/dev/sg3',
            },
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'Ibm',
                MODEL        => 'CBRCA146C3ETS0',
                device       => '/dev/sg2',
            },
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'Ibm',
                MODEL        => 'CBRCA146C3ETS0',
                device       => '/dev/sg1',
            },
            {
                DISKSIZE     => '139264',
                NAME         => 'foo',
                FIRMWARE     => 'C610',
                MANUFACTURER => 'Ibm',
                MODEL        => 'CBRCA146C3ETS0',
                device       => '/dev/sg0',
            }
        ]
    },
    sample3 => {
        name  => 'foo',
        disks => [
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD5',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDBR',
                device       => '/dev/sg5',
            },
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD5',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDBR',
                device       => '/dev/sg4',
            },
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD4',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDSP',
                device       => '/dev/sg3',
            },
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD5',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDBR',
                device       => '/dev/sg2',
            },
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD5',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDBR',
                device       => '/dev/sg1',
            },
            {
                DISKSIZE     => '285696',
                NAME         => 'foo',
                FIRMWARE     => 'HPD5',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'EG0300FBDBR',
                device       => '/dev/sg0',
            }
        ]
    }
);

my %controller_tests = (
    ctrl1 => [
        {
            SCSI_UNID => '0'
        }
    ]
);

plan tests =>
    (2 * scalar keys %disk_tests) +
    (scalar keys %controller_tests) +
    1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %disk_tests) {
    my $file = "resources/linux/mpt-status/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Linux::Storages::Lsilogic::_getDiskFromMptStatus(
        file       => $file,
        name       => $disk_tests{$test}->{name},
    );
    cmp_deeply(\@disks, $disk_tests{$test}->{disks}, "$test: parsing");
    delete $_->{device} foreach @disks;
    lives_ok {
        $inventory->addEntry(section => 'STORAGES', entry => $_) foreach @disks;
    } "$test: registering";
}

foreach my $test (keys %controller_tests) {
    my $file = "resources/linux/mpt-status/$test";
    my @devices = FusionInventory::Agent::Task::Inventory::Linux::Storages::Lsilogic::_getDevicesFromMptStatus(file => $file);
    cmp_deeply(\@devices, $controller_tests{$test}, "$test: mpt-status -p parsing");
}
