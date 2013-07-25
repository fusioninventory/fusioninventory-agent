#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::Virtualization::Jails;

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

plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'fatal' ],
    debug    => 1
);
my $inventory = FusionInventory::Agent::Inventory->new(logger => $logger);

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/jails/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::Jails::_getVirtualMachines(file => $file);
    cmp_deeply(\@machines, $tests{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $_)
            foreach @machines;
    } "$test: registering";
}
