#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::Linux::Networks;

my %ifconfig_tests = (
    'dell-xt2' => [
        {
            MACADDR     => 'A4:BA:DB:A5:F5:FA',
            STATUS      => 'Up',
            TYPE        => 'Ethernet',
            DESCRIPTION => 'eth0',
            IPMASK      => '255.255.255.0',
            IPADDRESS   => '192.168.0.5',
            IPADDRESS6  => 'fe80::a6ba:dbff:fea5:f5fa/64'
        },
        {
            DESCRIPTION => 'lo',
            STATUS      => 'Up',
            TYPE        => 'Local',
            IPMASK      => '255.0.0.0',
            IPADDRESS   => '127.0.0.1',
            IPADDRESS6  => '::1/128',
        },
        {
            MACADDR     => '4E:8C:81:ED:9B:35',
            DESCRIPTION => 'pan0',
            STATUS      => 'Down',
            TYPE        => 'Ethernet',
        },
        {
            DESCRIPTION => 'sit0',
            STATUS      => 'Down',
            TYPE        => 'IPv6-in-IPv4',
        },
        {
            MACADDR     => '00:24:D6:6F:81:3A',
            STATUS      => 'Up',
            TYPE        => 'Ethernet',
            DESCRIPTION => 'wlan0',
            IPMASK      => '255.255.192.0',
            IPADDRESS   => '78.251.91.204',
            IPADDRESS6  => 'fe80::224:d6ff:fe6f:813a/64'
        }
    ],
    'linux-bonding' => [
        {
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:50:56:AD:00:0E',
            DESCRIPTION => 'bond0',
            STATUS      => 'Up',
            TYPE        => 'Ethernet',
            IPADDRESS6  => 'fe80::250:56ff:fead:e/64',
            IPADDRESS   => '192.168.1.181'
        },
        {
            MACADDR     => '00:50:56:AD:00:0E',
            DESCRIPTION => 'eth0',
            STATUS      => 'Up',
            TYPE       => 'Ethernet'
        },
        {
            IPMASK      => '255.0.0.0',
            DESCRIPTION => 'lo',
            STATUS      => 'Up',
            TYPE        => 'Local',
            IPADDRESS6  => '::1/128',
            IPADDRESS   => '127.0.0.1'
        } 
    ]
);

my %ipaddrshow_tests = (
    'ip_addr-1' => [
        {
            IPSUBNET    => '127.0.0.0',
            IPMASK      => '255.0.0.0',
            STATUS      => 'Up',
            DESCRIPTION => 'lo',
            IPADDRESS6  => '::1',
            IPADDRESS   => '127.0.0.1'
        },
        {
            IPSUBNET    => '192.168.0.0',
            IPMASK      => '255.255.255.0',
            MACADDR     => '00:23:18:91:db:8d',
            STATUS      => 'Up',
            DESCRIPTION => 'eth0',
            IPADDRESS6  => 'fe80::223:18ff:fe91:db8d',
            IPADDRESS   => '192.168.0.10'
        },
        {
            STATUS      => 'Up',
            DESCRIPTION => 'tun0'
        },
        {
            STATUS      => 'Up',
            DESCRIPTION => 'tun1'
        },
        {
            MACADDR     => 'e8:39:df:3f:7d:ef',
            STATUS      => 'Down',
            DESCRIPTION => 'wlan0'
        }
    ],
    'ip_addr-2' => [
        {
            IPSUBNET    => '127.0.0.0',
            IPMASK      => '255.0.0.0',
            STATUS      => 'Up',
            DESCRIPTION => 'lo',
            IPADDRESS6  => '::1',
            IPADDRESS   => '127.0.0.1'
        },
        {
            IPSUBNET    => '172.16.0.0',
            IPMASK      => '255.255.128.0',
            MACADDR     => '0f:0f:0f:0f:0f:0f',
            STATUS      => 'Up',
            DESCRIPTION => 'eth0',
            IPADDRESS6  => 'fe80::201:29ff:fed1:feb4',
            IPADDRESS   => '172.16.0.201'
        },
        {
            STATUS      => 'Down',
            DESCRIPTION => 'eql'
        },
        {
            STATUS      => 'Down',
            DESCRIPTION => 'sit0'
        }
    ]
);

plan tests =>
    int (keys %ifconfig_tests) +
    int (keys %ipaddrshow_tests);

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/generic/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::Linux::Networks::_parseIfconfig(file => $file);
    is_deeply(\@results, $ifconfig_tests{$test}, $test);
}

foreach my $test (keys %ipaddrshow_tests) {
    my $file = "resources/linux/ip_addr/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::Linux::Networks::_parseIpAddrShow(file => $file);
    is_deeply(\@results, $ipaddrshow_tests{$test}, $test);
}
