#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::Networks;

my %tests = (
    7 => [
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (SSTP)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (IKEv2)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (L2TP)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (PPTP)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (PPPOE)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (IPv6)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (Network Monitor)',
            IPDHCP      => undef
        },
        {
            'dns' => '192.168.0.254',
            'IPMASK6' => [
                       '64'
                     ],
            'IPMASK' => [
                      '255.255.255.0'
                    ],
            'IPGATEWAY' => '192.168.0.254',
            MACADDR     => 'F4:6D:04:97:2D:3E',
            STATUS      => 'Up',
            'IPADDRESS6' => [
                          'fe80::311a:2127:dded:6618'
                        ],
            IPDHCP      => '192.168.0.254',
            'IPSUBNET' => [
                        '192.168.0.0'
                      ],
            MTU         => undef,
            'IPSUBNET6' => [],
            DESCRIPTION => 'Realtek PCIe GBE Family Controller',
            'IPADDRESS' => [
                         '192.168.0.1'
                       ]
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'WAN Miniport (IP)',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'Carte Microsoft ISATAP',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'RAS Async Adapter',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'Microsoft Teredo Tunneling Adapter',
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => '00:26:83:12:FB:0B',
            STATUS      => 'Up',
            DESCRIPTION => "P\x{e9}riph\x{e9}rique Bluetooth (r\x{e9}seau personnel)",
            IPDHCP      => undef
        },
        {
            MTU         => undef,
            MACADDR     => undef,
            STATUS      => 'Up',
            DESCRIPTION => 'Carte Microsoft ISATAP',
            IPDHCP      => undef
        }
    ],
);

plan tests => scalar keys %tests;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Input::Win32::Networks'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getWmiObjects',
        mockGetWmiObjects($test)
    );

    my @interfaces = FusionInventory::Agent::Task::Inventory::Input::Win32::Networks::_getInterfaces();
    is_deeply(
        \@interfaces,
        $tests{$test},
        "$test sample"
    );
}
