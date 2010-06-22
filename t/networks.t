#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;
use Test::More;
use FindBin;

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
            DESCRIPTION => 'eth0'
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '1',
            DESCRIPTION => 'lo',
            STATUS      => 'Up',
            TYPE        => 'Boucle',
            IPDHCP      => undef
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '1',
            DESCRIPTION => 'sit0',
            STATUS      => 'Down',
            TYPE        => 'IPv6-dans-IPv4',
            IPDHCP      => undef
        },
        {
            SLAVES      => '',
            VIRTUALDEV  => '0',
            MACADDR     => '00:24:D6:6F:81:3A',
            STATUS      => 'Down',
            TYPE        => 'Wifi',
            IPDHCP      => undef,
            PCISLOT     => '0000:0c:00.0',
            DRIVER      => 'iwlagn',
            DESCRIPTION => 'wlan0'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/ifconfig/$test";
    my $result = FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks::parseIfconfig($file, '<', undef);
    is_deeply($tests{$test}, $result, $test);
}
