#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Virtualization::Parallels;

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
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::Parallels::_parsePrlctlA(file => $file);
    cmp_deeply(\@machines, $tests{$test}, $test);
}
