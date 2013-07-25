#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::Linux::iLO;

my %tests = (
    'sample1' => {
        IPGATEWAY   => '192.168.10.254',
        IPMASK      => '255.255.248.0',
        STATUS      => 'Up',
        SPEED       => '10',
        TYPE        => 'Ethernet',
        IPSUBNET    => '192.168.8.0',
        MANAGEMENT  => 'iLO',
        DESCRIPTION => 'Management Interface - HP iLO',
        IPADDRESS   => '192.168.10.1'
    },
    'sample2' => {
        STATUS      => 'Down',
        TYPE        => 'Ethernet',
        MANAGEMENT  => 'iLO',
        DESCRIPTION => 'Management Interface - HP iLO',
        IPSUBNET    => undef
    }
);

plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'fatal' ],
    debug    => 1
);
my $inventory = FusionInventory::Agent::Inventory->new(logger => $logger);

foreach my $test (keys %tests) {
    my $file = "resources/linux/hponcfg/$test";
    my $interface = FusionInventory::Agent::Task::Inventory::Linux::iLO::_parseHponcfg(file => $file);
    cmp_deeply($interface, $tests{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'NETWORKS', entry => $interface);
    } 'no unknown fields';
}
