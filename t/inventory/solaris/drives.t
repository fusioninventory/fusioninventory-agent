#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::Drives;

my %tests_mount = (
    'mount_-v_sample1' => {
        'ctfs' => 'ctfs',
        '/' => 'vxfs',
        '/dev' => 'lofs',
        'mnttab' => 'mntfs',
        'objfs' => 'objfs',
        'proc' => 'proc',
        'swap' => 'tmpfs',
        'fd' => 'fd'
    } 
);

plan tests => scalar keys %tests_mount;

foreach my $test (keys %tests_mount) {
    my $file = "resources/solaris/mount/$test";
    my %storages = FusionInventory::Agent::Task::Inventory::Input::Solaris::Drives::_getFsTypeFromMount(file => $file);
    is_deeply(\%storages, $tests_mount{$test}, $test);
}
