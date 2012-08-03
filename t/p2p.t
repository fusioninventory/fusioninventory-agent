#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Deploy::P2P;
use Test::More tests => 5;

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
    },
    {
    input => [
"===========================================================================",
"Liste d'Interfaces",
"  8 ...00 03 ff 1d 00 5d ...... Carte Fast Ethernet PCI Ó base de Intel 21140",
"mulÚe)",
"  1 ........................... Software Loopback Interface 1",
"  9 ...00 00 00 00 00 00 00 e0  isatap.{0EE688A4-93B8-4F20-8138-E2A1C877F8FE}",
" 10 ...02 00 54 55 4e 01 ...... Teredo Tunneling Pseudo-Interface",
" 11 ...00 00 00 00 00 00 00 e0  6TO4 Adapter",
"===========================================================================",
" ",
"IPv4 Table de routage",
"===========================================================================",
"Itinéraires actifs :",
"Destination réseau    Masque réseau  Adr. passerelle   Adr. interface Métrique",
"          0.0.0.0          0.0.0.0     129.47.0.254      129.47.0.93    276",
"        127.0.0.0        255.0.0.0         On-link         127.0.0.1    306",
"        127.0.0.1  255.255.255.255         On-link         127.0.0.1    306",
"  127.255.255.255  255.255.255.255         On-link         127.0.0.1    306",
"       129.47.0.0    255.255.255.0         On-link       129.47.0.93    276",
"      129.47.0.93  255.255.255.255         On-link       129.47.0.93    276",
"     129.47.0.255  255.255.255.255         On-link       129.47.0.93    276",
"        224.0.0.0        240.0.0.0         On-link         127.0.0.1    306",
"        224.0.0.0        240.0.0.0         On-link       129.47.0.93    276",
"  255.255.255.255  255.255.255.255         On-link         127.0.0.1    306",
"  255.255.255.255  255.255.255.255         On-link       129.47.0.93    276",
"===========================================================================",
"Itinéraires persistants :",
"  Adresse réseau    Masque réseau  Adresse passerelle Métrique",
"          0.0.0.0          0.0.0.0     129.47.0.254  Par défaut",
"===========================================================================",
" ",
"IPv6 Table de routage",
"===========================================================================",
"Itinéraires actifs :",
" If Metric Network Destination      Gateway",
" 11   1125 ::/0                     2002:c058:6301::c058:6301",
"  1    306 ::1/128                  On-link",
" 11   1025 2002::/16                On-link",
" 11    281 2002:812f:5d::812f:5d/128",
"                                    On-link",
"  9    281 fe80::200:5efe:129.47.0.93/128",
"                                    On-link",
"  1    306 ff00::/8                 On-link",
"===========================================================================",
"Itinéraires persistants :",
"  Aucun",


    ],
    output => [
          {
            'ip' => '129.47.0.93',
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
