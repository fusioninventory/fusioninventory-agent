#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Deploy::P2P;
use Test::More tests => 4;

my @routePrintTest = (
{

    input => [
'===========================================================================',
'Interface List',
'0x1 ........................... MS TCP Loopback interface',
'0x2 ...52 54 00 17 24 56 ...... Realtek RTL8139 Family PCI Fast Ethernet NIC - Packet Scheduler Miniport',
'0x10004 ...00 ff d8 2a 28 86 ...... Juniper Network Connect Virtual Adapter - Packet Scheduler Miniport',
'===========================================================================',
'===========================================================================',
'Active Routes:',
'Network Destination        Netmask          Gateway       Interface  Metric',
'          0.0.0.0          0.0.0.0         10.0.2.2       10.0.2.15       20',
'         10.0.2.0    255.255.255.0        10.0.2.15       10.0.2.15       20',
'        10.0.2.15  255.255.255.255        127.0.0.1       127.0.0.1       20',
'   10.255.255.255  255.255.255.255        10.0.2.15       10.0.2.15       20',
'        127.0.0.0        255.0.0.0        127.0.0.1       127.0.0.1       1',
'        224.0.0.0        240.0.0.0        10.0.2.15       10.0.2.15       20',
'  255.255.255.255  255.255.255.255        10.0.2.15       10.0.2.15       1',
'  255.255.255.255  255.255.255.255        10.0.2.15           10004       1',
'Default Gateway:          10.0.2.2',
'===========================================================================',
'Persistent Routes:',
'  None' ],
     output => [
            {
                'ip' => '10.0.2.15',
                'mask' => '255.255.255.0'
            }
        ]
    }
);

my @tests = (
    {
        name => 'Ignore',
        test => [
            {
                ip   => '127.0.0.1',
                mask => '255.0.0.0'
            }
        ],
        ret => [
        ]
    },
    {
        name => '192.168.5.5',
        test => [
            {
                ip   => '192.168.5.5',
                mask => '255.255.255.0'
            },
        ],
        ret => [
          '192.168.5.2',
          '192.168.5.3',
          '192.168.5.4',
          '192.168.5.5',
          '192.168.5.6',
          '192.168.5.7'
        ]
    },
    {
        name => '10.5.6.200',
        test => [
            {
                ip   => '10.5.6.200',
                mask => '255.255.250.0'
            }
        ],
        ret => [
          '10.5.6.197',
          '10.5.6.198',
          '10.5.6.199',
          '10.5.6.200',
          '10.5.6.201',
          '10.5.6.202'
        ]
    },

);

foreach my $test (@tests) {
    my @ret = FusionInventory::Agent::Task::Deploy::P2P::_computeIPToTest(
        undef, # $logger
        $test->{test}, 6 );
    is_deeply(\@ret, $test->{ret}, $test->{name});
}


foreach my $test (@routePrintTest) {
    my @ret = FusionInventory::Agent::Task::Deploy::P2P::_parseWin32Route(@{$test->{input}});
    is_deeply(\@ret, $test->{output}, "Win32 'route print' parsing");
}
