#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Virtualization::Jails;

my %tests = (
    sample1 => [
        {
            NAME      => 'xmpp-test3',
            STATUS    => 'running',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'xmpp-test2',
            STATUS    => 'running',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'xmpp-test1',
            STATUS    => 'running',
            VMTYPE    => 'jail',
        },
        {
            NAME      => 'noname.local',
            STATUS    => 'running',
            VMTYPE    => 'jail',
        },
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/jails/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::Jails::_getVirtualMachines(file => $file);
    cmp_deeply(\@machines, $tests{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $_)
            foreach @machines;
    } "$test: registering";
}
