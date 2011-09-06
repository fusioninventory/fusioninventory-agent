#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Adaptec;
use Test::More;

plan tests => 2;

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
    }
);

foreach my $test (keys %tests) {
    my $file = "resources/linux/proc/scsi/$test";
    my @disks = FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Adaptec::_getDisksFromProc(
        file       => $file,
        controller => $tests{$test}->{controller},
        name       => $tests{$test}->{name},
    );
    is_deeply(\@disks, $tests{$test}->{disks}, $test);
}
