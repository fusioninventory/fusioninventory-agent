#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::AIX::LVM;

my %physical_volume_tests = (
    'aix-6.1-hdisk0' => {
        ATTR        => 'VG rootvg',
        DEVICE      => '/dev/aix-6.1-hdisk0',
        FORMAT      => 'AIX PV',
        FREE        => 10816,
        PE_SIZE     => 64,
        PV_PE_COUNT => 543,
        PV_UUID     => '00c6ce9d4f2c404a',
        SIZE        => 34752,
    },
    'aix-6.1-hdisk1' => {
        ATTR        => 'VG altinst_rootvg',
        DEVICE      => '/dev/aix-6.1-hdisk1',
        FORMAT      => 'AIX PV',
        PV_UUID     => '00c6ce9d53fc4e84',
    },
    'aix-6.1-hdisk2' =>{
        ATTR        => 'VG vg_apps01',
        DEVICE      => '/dev/aix-6.1-hdisk2',
        FORMAT      => 'AIX PV',
        FREE        => 12160,
        PE_SIZE     => 128,
        PV_PE_COUNT => 799,
        PV_UUID     => '00c6ce9d55b465a3',
        SIZE        => 102272,
    },
    'aix-6.1-hdisk3' => {
        ATTR        => 'VG vg_apps01',
        DEVICE      => '/dev/aix-6.1-hdisk3',
        FORMAT      => 'AIX PV',
        FREE        => 10112,
        PE_SIZE     => 128,
        PV_PE_COUNT => 239,
        PV_UUID     => '00c6ce9db4ee2922',
        SIZE        => 30592,
    },
);

my %logical_volume_tests = (
    hd1 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd1',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.8',
        SEG_COUNT => 8,
        SIZE      => 512
    },
    hd2 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd2',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.5',
        SEG_COUNT => 48,
        SIZE      => 3072
    },
    hd3 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd3',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.7',
        SEG_COUNT => 64,
        SIZE      => 4096
    },
    hd4 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd4',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.4',
        SEG_COUNT => 8,
        SIZE      => 512
    },
    hd5 => {
        ATTR      => 'Type boot',
        LV_NAME   => 'hd5',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.1',
        SEG_COUNT => 1,
        SIZE      => 64
    },
    hd6 => {
        ATTR      => 'Type paging',
        LV_NAME   => 'hd6',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.2',
        SEG_COUNT => 129,
        SIZE      => 8256
    },
    hd8 => {
        ATTR      => 'Type jfs2log',
        LV_NAME   => 'hd8',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.3',
        SEG_COUNT => 1,
        SIZE      => 64
    },
    hd9var => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd9var',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.6',
        SEG_COUNT => 16,
        SIZE      => 1024
    },
    hd10opt => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd10opt',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.9',
        SEG_COUNT => 32,
        SIZE      => 2048
    },
    hd11admin => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'hd11admin',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.10',
        SEG_COUNT => 2,
        SIZE      => 128
    },
    fslv00 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'fslv00',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.14',
        SEG_COUNT => 2,
        SIZE      => 128
    },
    fslv01 => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'fslv01',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.17',
        SEG_COUNT => 16,
        SIZE      => 1024
    },
    dooncelv => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'dooncelv',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.13',
        SEG_COUNT => 5,
        SIZE      => 320
    },
    lg_dumplv => {
        ATTR      => 'Type sysdump',
        LV_NAME   => 'lg_dumplv',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.11',
        SEG_COUNT => 20,
        SIZE      => 1280
    },
    livedump => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'livedump',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.12',
        SEG_COUNT => 4,
        SIZE      => 256
    },
    lv_auditlog => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'lv_auditlog',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.15',
        SEG_COUNT => 2,
        SIZE      => 128
    },
    lv_tpc => {
        ATTR      => 'Type jfs2',
        LV_NAME   => 'lv_tpc',
        LV_UUID   => '00c6ce9d00004c000000014302ee7629.16',
        SEG_COUNT => 16,
        SIZE      => 1024
    },
);

my %logical_volume_names_tests = (
    'aix-6.x-l_rootvg' => [
        'hd5',
        'hd6',
        'hd8',
        'hd4',
        'hd2',
        'hd9var',
        'hd3',
        'hd1',
        'hd10opt',
        'lg_dumplv',
        'loglv05',
        'ptf0-0',
        'paging00',
        'paging01',
        'paging02',
    ],
    'aix-6.1-l_altinst_rootvg' => [
    ],
    'aix-6.1-l_rootvg' => [
        'hd5',
        'hd6',
        'hd8',
        'hd4',
        'hd2',
        'hd9var',
        'hd3',
        'hd1',
        'hd10opt',
        'hd11admin',
        'lg_dumplv',
        'livedump',
        'dooncelv',
        'fslv00',
        'lv_auditlog',
        'lv_tpc',
        'fslv01'
    ],
    'aix-6.1-l_vg_apps01' => [
        'lv_web1',
        'lv_ihs1',
        'lv_apps1',
        'lv_depl',
        'lv_glvmt',
        'lv_ora1',
        'lv_pvcs',
        'lv_glvpack',
        'lv_glvsc',
        'lv_glvlfw',
    ]
);

plan tests =>
    (2 * scalar keys %physical_volume_tests) +
    (2 * scalar keys %logical_volume_tests) +
    (scalar keys %logical_volume_names_tests) +
    1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %physical_volume_tests) {
    my $file = "resources/aix/lspv/$test";
    my $device = FusionInventory::Agent::Task::Inventory::AIX::LVM::_getPhysicalVolume(file => $file, name => $test);
    cmp_deeply($device, $physical_volume_tests{$test}, "$test: lspv parsing");
    lives_ok {
        $inventory->addEntry(section => 'PHYSICAL_VOLUMES', entry => $device);
    } "$test: registering";
}

foreach my $test (keys %logical_volume_tests) {
    my $file = "resources/aix/lslv/$test";
    my $device = FusionInventory::Agent::Task::Inventory::AIX::LVM::_getLogicalVolume(file => $file, name => $test);
    cmp_deeply($device, $logical_volume_tests{$test}, "$test: lslv parsing");
    lives_ok {
        $inventory->addEntry(section => 'LOGICAL_VOLUMES', entry => $device);
    } "$test: registering";
}

foreach my $test (keys %logical_volume_names_tests) {
    my $file = "resources/aix/lsvg/$test";
    my @names = FusionInventory::Agent::Task::Inventory::AIX::LVM::_getLogicalVolumesFromGroup(file => $file);
    cmp_deeply(\@names, $logical_volume_names_tests{$test}, "$test: lsvg parsing");
}
