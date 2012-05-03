#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Adaptec;

my %tests = (
    linux1 => {
        controller => 'scsi0',
        name       => 'foo',
        disks   => [
            {
                NAME         => 'foo',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                MODEL        => 'SAMSUNG',
                MANUFACTURER => 'Samsung',
                FIRMWARE     => 'VBM2',
                DEVICE       => '/dev/sg0'
            }
        ]
    },
    linux2 => {
        controller => 'scsi0',
        name       => 'foo',
        disks      => [
            {
                NAME         => 'foo',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                MODEL        => 'HUS151436VL3800',
                MANUFACTURER => 'Hitachi',
                FIRMWARE     => 'S3C0',
                DEVICE       => '/dev/sg1'
            },
            {
                NAME         => 'foo',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                MODEL        => 'HUS151436VL3800',
                MANUFACTURER => 'Hitachi',
                FIRMWARE     => 'S3C0',
                DEVICE       => '/dev/sg2'
            }
        ]
    },
    linux3 => {
        controller => 'scsi0',
        name       => 'foo',
        disks      => [
            {
                NAME         => 'foo',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                MODEL        => 'UJDA782',
                MANUFACTURER => 'UJDA782',
                FIRMWARE     => 'VA13',
                DEVICE       => '/dev/sg0'
            },
        ]
    },
    linux4 => {
        controller => 'scsi0',
        name       => 'foo',
        disks      => [
            {
                NAME         => 'foo',
                FIRMWARE     => 'V1.0',
                MANUFACTURER => 'Drive',
                MODEL        => 'Drive',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg0'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'V1.0',
                MANUFACTURER => 'Drive',
                MODEL        => 'Drive',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg1'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg2'
                },
                {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg3'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg4'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg5'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg6'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => 'BA23',
                MANUFACTURER => 'Seagate',
                MODEL        => 'ST3300655SS',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg7'
            },
            {
                NAME         => 'foo',
                FIRMWARE     => '1.06',
                MANUFACTURER => 'VSC7160',
                MODEL        => 'VSC7160',
                DESCRIPTION  => 'SATA',
                TYPE         => 'disk',
                DEVICE       => '/dev/sg8'
            }
        ]
    }
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/linux/proc/scsi/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Adaptec::_getDisksFromProc(
        file       => $file,
        controller => $tests{$test}->{controller},
        name       => $tests{$test}->{name},
    );
    is_deeply(\@disks, $tests{$test}->{disks}, $test);
}
