#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

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

plan tests => int (keys %tests);

foreach my $test (keys %tests) {
    my $file = "resources/linux/hponcfg/$test";
    my $results = FusionInventory::Agent::Task::Inventory::Linux::iLO::_parseHponcfg(file => $file);
    cmp_deeply($results, $tests{$test}, $test);
}
