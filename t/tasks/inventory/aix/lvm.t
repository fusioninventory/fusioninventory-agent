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


plan tests =>
    (2 * scalar keys %lspv_tests) +
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
