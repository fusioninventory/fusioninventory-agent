#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Virtualization::Vmsystem;

my %tests = (
    status_sample1 => 999
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/openvz/$test";
    my $vmid = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Vmsystem::_getOpenVZVmID(file => $file);
    cmp_deeply($vmid, $tests{$test}, $test);
}
