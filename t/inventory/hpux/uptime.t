#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::HPUX::Uptime;

my %tests = (
    sample1 => '00-04-02 23:35:00'
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file1 = "resources/hpux/uptime/$test";
    my $date = FusionInventory::Agent::Task::Inventory::Input::HPUX::Uptime::_getUptime(file => $file1);
    is($date, $tests{$test}, "$test uptime parsing");
}
