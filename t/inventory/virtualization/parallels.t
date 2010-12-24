#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Virtualization::Parallels;
use FusionInventory::Agent::Logger;
use Test::More;

my %tests = (
    sample1 => [
        {
            VMTYPE    => 'Parallels',
            NAME      => 'Ubuntu',
            SUBSYSTEM => 'Parallels',
            STATUS    => 'stopped',
            UUID      => '{bc993872-c70f-40bf-b2e2-94d9f080eb55}'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/prlctl/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::Parallels::_parsePrlctlA(file => $file);
    is_deeply(\@machines, $tests{$test}, $test);
}
