#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Linux::Networks::FiberChannel;

my %tests = (
    'sample1' => [
        {
            STATUS      => 'Up',
            SPEED       => '4 Gbit',
            TYPE        => 'fiberchannel',
            DESCRIPTION => 'host5',
            MACADDR     => '10:00:00:00:c9:af:df:c6',
        },
        {
            STATUS      => 'Up',
            SPEED       => '4 Gbit',
            TYPE        => 'fiberchannel',
            DESCRIPTION => 'host6',
            MACADDR     => '10:00:00:00:c9:af:df:c7',
        },
    ],
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/linux/systool/$test";
    my @interfaces = FusionInventory::Agent::Task::Inventory::Linux::Networks::FiberChannel::_getInterfacesFromFcHost(file => $file);
    cmp_deeply(\@interfaces, $tests{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'NETWORKS', entry => $_)
        foreach @interfaces;
    } 'no unknown fields';
}
