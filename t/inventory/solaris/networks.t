#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks;

my %ifconfig_tests = (
    'solaris-10' => [
        {
            IPSUBNET    => '127.0.0.0',
            IPGATEWAY   => undef,
            IPMASK      => '255.0.0.0',
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            SPEED       => undef,
            IPADDRESS   => '127.0.0.1'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.254.0',
            MACADDR     => '00:15:17:7a:60:31',
            STATUS      => 'Up',
            SPEED       => '',
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'aggr1',
            IPADDRESS   => '130.79.0.1'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.128',
            MACADDR     => '00:15:17:7a:60:30',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'e1000g0',
            IPADDRESS   => '130.79.0.2'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.128',
            MACADDR     => '00:15:17:7a:60:32',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.0.0',
            DESCRIPTION => 'e1000g2',
            IPADDRESS   => '130.79.0.3'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:15:17:7a:60:33',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '192.168.19.0',
            DESCRIPTION => 'e1000g3',
            IPADDRESS   => '192.168.19.1'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.224',
            MACADDR     => '00:15:17:8a:48:30',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '130.79.255.0',
            DESCRIPTION => 'e1000g4',
            IPADDRESS   => '130.79.255.1'
        },
        {
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:15:17:6a:44:4c',
            STATUS      => 'Up',
            SPEED       => undef,
            IPSUBNET    => '192.168.20.0',
            DESCRIPTION => 'igb0',
            IPADDRESS   => '192.168.20.1'
        }
    ],

);

plan tests =>
    int (keys %ifconfig_tests);

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/generic/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks::_getInterfaces(file => $file);
    is_deeply(\@results, $ifconfig_tests{$test}, $test);
}

