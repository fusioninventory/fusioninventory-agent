#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::BSD::Networks;

my %ifconfig_tests = (
    'freebsd-8.1' => [
        {
            DESCRIPTION => 're0',
            STATUS      => 'Up',
            MTU         => '1500',
            TYPE        => 'Ethernet',
            MACADDR     => 'c8:0a:a9:3f:35:fa',
            IPADDRESS   => '129.132.95.98',
            IPMASK      => '255.255.255.192',
            IPSUBNET    => '129.132.95.64',
        },
        {
            DESCRIPTION => 'fwe0',
            MTU         => '1500',
            MACADDR     => '02:24:1b:9d:ca:01',
        },
        {
            DESCRIPTION => 'fwip0',
            MTU         => '1500',
        },
        {
            DESCRIPTION => 'lo0',
            MTU         => '16384',
            STATUS      => 'Up',
            MACADDR     => undef,
            IPADDRESS6  => 'fe80::1',
            IPMASK6     => 'ffff:ffff:ffff:ffff::',
            IPSUBNET6   => 'fe80::',
        },
        {
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            MTU         => '16384',
            MACADDR     => undef,
            IPADDRESS6  => '::1',
            IPMASK6     => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            IPSUBNET6   => '::1',
        },
        {
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            MTU         => '16384',
            MACADDR     => undef,
            IPADDRESS   => '127.0.0.1',
            IPSUBNET    => '127.0.0.0',
            IPMASK      => '255.0.0.0',
        },
        {
            DESCRIPTION => 'vboxnet0',
            MTU         => '1500',
            MACADDR     => '0a:00:27:00:00:00',
        },
        {
            DESCRIPTION => 'tun0',
            STATUS      => 'Up',
            MTU         => '1500',
            MACADDR     => undef,
            IPADDRESS   => '192.168.200.6',
            IPSUBNET    => '192.168.200.6',
            IPMASK      => '255.255.255.255',
        }
    ],
    'freebsd-bis' => [
        {
            DESCRIPTION => 'bce0',
            STATUS      => 'Up',
            MTU         => '1500',
            TYPE        => 'Ethernet',
            MACADDR     => '00:16:18:87:ca:b5',
            IPADDRESS   => '11.105.11.105',
            IPMASK      => '255.255.255.192',
            IPSUBNET    => '11.105.11.64',

        },
        {
            DESCRIPTION => 'bce0',
            STATUS      => 'Up',
            MTU         => '1500',
            TYPE        => 'Ethernet',
            MACADDR     => '00:16:18:87:ca:b5',
            IPADDRESS   => '11.105.11.110',
            IPMASK      => '255.255.255.255',
            IPSUBNET    => '11.105.11.110',

        },
        {
            DESCRIPTION => 'bce0',
            STATUS      => 'Up',
            MTU         => '1500',
            TYPE        => 'Ethernet',
            MACADDR     => '00:16:18:87:ca:b5',
            IPADDRESS   => '11.105.11.111',
            IPMASK      => '255.255.255.255',
            IPSUBNET    => '11.105.11.111',

        },
        {
            DESCRIPTION => 'bce1',
            STATUS      => 'Up',
            MTU         => '1500',
            TYPE        => 'Ethernet',
            MACADDR     => '00:16:18:87:ca:b6',
            IPADDRESS   => '192.168.12.105',
            IPMASK      => '255.255.255.0',
            IPSUBNET    => '192.168.12.0'

        },
        {
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            MTU         => '16384',
            MACADDR     => undef,
            IPADDRESS6  => 'fe80::1',
            IPMASK6     => 'ffff:ffff:ffff:ffff::',
            IPSUBNET6   => 'fe80::'

        },
        {
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            MTU         => '16384',
            MACADDR     => undef,
            IPADDRESS6  => '::1',
            IPMASK6     => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            IPSUBNET6   => '::1'

        },
        {
            DESCRIPTION => 'lo0',
            STATUS      => 'Up',
            MTU         => '16384',
            MACADDR     => undef,
            IPADDRESS   => '127.0.0.1',
            IPMASK      => '255.0.0.0',
            IPSUBNET    => '127.0.0.0'

        }
    ]
);

plan tests => scalar keys %ifconfig_tests;

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/generic/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::Input::BSD::Networks::_parseIfconfig(file => $file);
    is_deeply(\@results, $ifconfig_tests{$test}, $test);
}
