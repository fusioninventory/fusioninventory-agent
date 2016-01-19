#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::Exception;
use Test::MockModule;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Inventory;
use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::Storages;

my %tests = (
    'win7-sp1-x64' => [
        {
            MANUFACTURER => '(Lecteurs de disque standard)',
            MODEL        => 'VBOX HARDDISK ATA Device',
            DESCRIPTION  => 'Lecteur de disque',
            NAME         => '\\\\.\\PHYSICALDRIVE0',
            TYPE         => 'Fixed hard disk media',
            INTERFACE    => 'IDE',
            FIRMWARE     => '1.0',
            SCSI_COID    => '2',
            SCSI_LUN     => '0',
            SCSI_UNID    => '0',
            DISKSIZE     => 102398,
            SERIAL       => 'VB2cff0f95-b2f7db11',
        },
        {
            MANUFACTURER => '(Lecteurs de disque standard)',
            MODEL        => 'Msft Virtual Disk SCSI Disk Device',
            DESCRIPTION  => 'Lecteur de disque',
            NAME         => '\\\\.\\PHYSICALDRIVE1',
            TYPE         => 'Fixed hard disk media',
            INTERFACE    => 'SCSI',
            FIRMWARE     => '1.0',
            SCSI_COID    => '32',
            SCSI_LUN     => '1',
            SCSI_UNID    => '0',
            DISKSIZE     => 94,
        },
    ],
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Agent::Inventory->new();

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Win32::Storages'
);

foreach my $test (sort keys %tests) {
    $module->mock(
        'getWMIObjects',
        mockGetWMIObjects($test)
    );

    my @storages = FusionInventory::Agent::Task::Inventory::Win32::Storages::_getDrives(
            class => 'Win32_DiskDrive'
    );
    cmp_deeply(
        \@storages,
        $tests{$test},
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'STORAGES', entry => $_)
            foreach @storages;
    } "$test: registering";
}
