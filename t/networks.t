#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;
use Test::More;
use FindBin;
use Net::IP;

my %tests = (
    'dell-xt2' => [
        {
            SLAVES      => '',
            VIRTUALDEV  => '0',
            MACADDR     => 'A4:BA:DB:A5:F5:FA',
            STATUS      => 'Up',
            TYPE        => 'Ethernet',
            IPDHCP      => undef,
            PCISLOT     => '0000:00:19.0',
            DRIVER      => 'e1000e',
            DESCRIPTION => 'eth0',
            IPGATEWAY   => undef,
            IPMASK      => '255.255.255.0',
            IPSUBNET    => '192.168.0.0',
            IPADDRESS   => '192.168.0.5'
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '1',
            DESCRIPTION => 'lo',
            STATUS      => 'Up',
            TYPE        => 'Local',
            IPDHCP      => undef,
            IPGATEWAY   => undef,
            IPMASK      => '255.0.0.0',
            IPSUBNET    => '127.0.0.0',
            IPADDRESS   => '127.0.0.1'
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '1',
            MACADDR     => '4E:8C:81:ED:9B:35',
            DESCRIPTION => 'pan0',
            STATUS      => 'Down',
            TYPE        => 'Ethernet',
            IPDHCP      => undef,
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '1',
            DESCRIPTION => 'sit0',
            STATUS      => 'Down',
            TYPE        => 'IPv6-in-IPv4',
            IPDHCP      => undef,
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '0',
            MACADDR     => '00:24:D6:6F:81:3A',
            STATUS      => 'Up',
            TYPE        => 'Wifi',
            IPDHCP      => undef,
            PCISLOT     => '0000:0c:00.0',
            DRIVER      => 'iwlagn',
            DESCRIPTION => 'wlan0',
            IPGATEWAY   => undef,
            IPMASK      => '255.255.192.0',
            IPSUBNET    => '78.251.64.0',
            IPADDRESS   => '78.251.91.204',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/ifconfig/$test";
    my $result = FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks::parseIfconfig($file, '<', undef);
    is_deeply($result, $tests{$test}, $test);
}
