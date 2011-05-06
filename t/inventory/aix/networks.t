#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

my %tests = (
    'aix-5.3' => [
        {
            DESCRIPTION => 'en0',
            TYPE        => '2-Port 10/100/1000 Base-TX PCI-X Adapter (14108902)',
            MACADDR     => '00:14:5E:4D:20:C6',
        },
        {
            DESCRIPTION => 'en1',
            TYPE        => '2-Port 10/100/1000 Base-TX PCI-X Adapter (14108902)',
            MACADDR     => '00:14:5E:4D:20:C7',
        }
      ],
    'aix-6.1' => [
        {
            DESCRIPTION => 'en0',
            TYPE        => 'Virtual I/O Ethernet Adapter (l-lan)',
            MACADDR     => 'D2:13:C0:15:3A:04',
        },
        {
            DESCRIPTION => 'en2',
            TYPE        => 'Logical Host Ethernet Port (lp-hea)',
            MACADDR     => '00:21:5E:A6:7C:D0',
        },
        {
            DESCRIPTION => 'en1',
            TYPE        => 'Logical Host Ethernet Port (lp-hea)',
            MACADDR     => '00:21:5E:A6:7C:C0',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lscfg/$test-en";
    my @interfaces = FusionInventory::Agent::Task::Inventory::OS::AIX::Networks::_parseLscfg(file => $file);
    is_deeply(\@interfaces, $tests{$test}, "interfaces: $test");
}
