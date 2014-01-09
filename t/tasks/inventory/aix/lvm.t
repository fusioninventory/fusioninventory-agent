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

my %lspv_tests = (
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
        FREE        => 10112,,
        PE_SIZE     => 128,
        PV_PE_COUNT => 239,
        PV_UUID     => '00c6ce9db4ee2922',
        SIZE        => 30592,,
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
    (2 * scalar keys %lspv_tests) +
    (scalar keys %logical_volume_names_tests) +
    1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %lspv_tests) {
    my $file = "resources/aix/lspv/$test";
    my $device = FusionInventory::Agent::Task::Inventory::AIX::LVM::_getPhysicalVolume(file => $file, name => $test);
    cmp_deeply($device, $lspv_tests{$test}, "lspv parsing: $test");
    lives_ok {
        $inventory->addEntry(section => 'PHYSICAL_VOLUMES', entry => $device);
    } "$test: registering";
}

foreach my $test (keys %logical_volume_names_tests) {
    my $file = "resources/aix/lsvg/$test";
    my @names = FusionInventory::Agent::Task::Inventory::AIX::LVM::_getLogicalVolumesFromGroup(file => $file);
    cmp_deeply(\@names, $logical_volume_names_tests{$test}, "logical volume list: $test");
}
