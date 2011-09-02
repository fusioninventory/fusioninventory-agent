#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::Input::Virtualization::Parallels;

use Test::More;

my %tests = (
    sample1 => [
        {
            VMTYPE    => 'Parallels',
            NAME      => 'Ubuntu Linux',
            SUBSYSTEM => 'Parallels',
            STATUS    => 'off',
            UUID      => 'bc993872-c70f-40bf-b2e2-94d9f080eb55'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/prlctl/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Parallels::_parsePrlctlA(file => $file);
    is_deeply(\@machines, $tests{$test}, $test);
}
