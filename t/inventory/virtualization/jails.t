#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Virtualization::Jails;

my %tests = (
    sample1 => [
        {
            NAME      => 'xmpp-test3',
            STATUS    => 'running',
            VMID      => '2',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'xmpp-test2',
            STATUS    => 'running',
            VMID      => '3',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'xmpp-test1',
            STATUS    => 'running',
            VMID      => '4',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'noname.local',
            STATUS    => 'running',
            VMID      => '5',
            VMTYPE    => 'jail',
        },
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/jails/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Jails::_getVirtualMachines(file => $file);
    cmp_deeply(\@machines, $tests{$test}, $test);
}
