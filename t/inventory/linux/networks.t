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
            IPADDRESS   => '192.168.0.5'
        },
        {
            DESCRIPTION => 'lo',
            STATUS      => 'Up',
            TYPE        => 'Local',
            IPMASK      => '255.0.0.0',
            IPADDRESS   => '127.0.0.1'
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
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/ifconfig/$test";
    my @results = FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks::_parseIfconfig(file => $file);
    is_deeply(\@results, $tests{$test}, $test);
}
