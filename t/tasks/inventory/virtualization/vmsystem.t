#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Virtualization::Vmsystem;

my %tests = (
    status_sample1 => 999
);

plan tests => (scalar keys %tests) + 2;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/openvz/$test";
    my $vmid = FusionInventory::Agent::Task::Inventory::Virtualization::Vmsystem::_getOpenVZVmID(file => $file);
    cmp_deeply($vmid, $tests{$test}, $test);
}

my $hardware = FusionInventory::Agent::Task::Inventory::Virtualization::Vmsystem::_getLibvirtLXC_UUID(
    file => 'resources/linux/proc/1-environ.txt'
);
ok($hardware eq '61568ec7-4ec9-4a26-89cd-94e29a91721a', '_getLibvirtLXC_UUID');

