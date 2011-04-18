#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;
use Test::More;

my %tests = (
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
            'IPMASK' => '255.255.255.0',
            'MACADDR' => '00:50:56:AD:00:0E',
            'DESCRIPTION' => 'bond0',
            'STATUS' => 'Up',
            'TYPE' => 'Ethernet',
            'IPADDRESS6' => 'fe80::250:56ff:fead:e/64',
            'IPADDRESS' => '192.168.1.181'
          },
          {
            'MACADDR' => '00:50:56:AD:00:0E',
            'DESCRIPTION' => 'eth0',
            'STATUS' => 'Up',
            'TYPE' => 'Ethernet'
          },
          {
            'IPMASK' => '255.0.0.0',
            'DESCRIPTION' => 'lo',
            'STATUS' => 'Up',
            'TYPE' => 'Local',
            'IPADDRESS6' => '::1/128',
            'IPADDRESS' => '127.0.0.1'
          } 
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks::_parseIfconfig(file => $file);
    is_deeply(\@results, $tests{$test}, $test);
}
