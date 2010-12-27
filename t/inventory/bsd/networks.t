#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::BSD::Networks;
use Test::More;

my %ifconfig_tests = (
    'freebsd-8.1' => [
        {
            MTU         => '1500',
            IPMASK      => '255.255.255.192',
            MACADDR     => 'c8:0a:a9:3f:35:fa',
            DESCRIPTION => 're0',
            STATUS      => 'Up',
            IPADDRESS   => '129.132.95.98'
        },
        {
            MTU         => '1500',
            MACADDR     => '02:24:1b:9d:ca:01',
            DESCRIPTION => 'fwe0',
            STATUS      => 'Down'
        },
        {
            MTU         => '1500',
            DESCRIPTION => 'fwip0',
            STATUS      => 'Down'
        },
        {
            MTU         => '16384',
            IPMASK      => '255.0.0.0',
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            IPADDRESS   => '127.0.0.1'
        },
        {
            MTU         => '1500',
            MACADDR     => '0a:00:27:00:00:00',
            DESCRIPTION => 'vboxnet0',
            STATUS      => 'Down'
        },
        {
            MTU         => '1500',
            IPMASK      => '255.255.255.255',
            DESCRIPTION => 'tun0',
            STATUS      => 'Up',
            IPADDRESS   => '192.168.200.6'
        }
    ]
);

my %netstat_tests = (
    openbsd => {
        'default'     => '10.0.1.1',
        '10.0.1/24'   => 'link#1',
        '10.0.1.1'    => '00:1d:7e:43:96:57',
        '10.0.1.100'  => '00:13:77:b3:cf:0c',
        '10.0.1.115'  => '127.0.0.1',
        '127/8'       => '127.0.0.1',
        '127.0.0.1'   => '127.0.0.1',
        '224/4'       => '127.0.0.1'
    },
    netbsd => {
        'default'     => '10.0.1.1',
        '10.0.1/24'   => 'link#1',
        '10.0.1.1'    => '00:1d:7e:43:96:57',
        '10.0.1.101'  => '00:1e:c2:0c:36:27',
        '10.0.1.124'  => '127.0.0.1',
        '127/8'       => '127.0.0.1',
        '127.0.0.1'   => '127.0.0.1',
    },
);

plan tests =>
    (scalar keys %ifconfig_tests) + 
    (scalar keys %netstat_tests);

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::BSD::Networks::_parseIfconfig(file => $file);
    is_deeply(\@results, $ifconfig_tests{$test}, $test);
}

foreach my $test (keys %netstat_tests) {
    my $file = "resources/netstat/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::BSD::Networks::_getRoutes(file => $file);
    is_deeply($results, $netstat_tests{$test}, $test);
}
