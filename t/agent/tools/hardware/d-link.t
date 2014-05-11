#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'd-link/DP_303.1.walk' => [
        {
            TYPE         => 'NETWORKING',
            MANUFACTURER => 'D-Link',
            VENDOR       => 'D-Link',
            DESCRIPTION  => 'D-Link DP-303 Print Server',

            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5d:57:b3:c4',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'NETWORKING',
                MANUFACTURER => 'D-Link',
                VENDOR       => 'D-Link',
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C4',
                MAC          => '00:05:5d:57:b3:c4',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => '10/100M Fast Ethernet Port',
                        IFDESCR          => '10/100M Fast Ethernet Port',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1518',
                        MAC              => '00:05:5d:57:b3:c4',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3313005088',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '124761128',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'd-link/DP_303.2.walk' => [
        {
            TYPE         => 'NETWORKING',
            MANUFACTURER => 'D-Link',
            VENDOR       => 'D-Link',
            DESCRIPTION  => 'D-Link DP-303 Print Server',

            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5d:57:b3:c7',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'NETWORKING',
                MANUFACTURER => 'D-Link',
                VENDOR       => 'D-Link',
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C7',
                MAC          => '00:05:5d:57:b3:c7',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => '10/100M Fast Ethernet Port',
                        IFDESCR          => '10/100M Fast Ethernet Port',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1518',
                        MAC              => '00:05:5d:57:b3:c7',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '13974939',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '301006',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
);

plan skip_all => 'SNMP walks database required'
    if !$ENV{SNMPWALK_DATABASE};
plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new(debug => 0);

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    my %discovery = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share',
        logger  => $logger
    );
    cmp_deeply(
        \%discovery,
        $tests{$test}->[0],
        "$test: discovery"
    );

    my $inventory = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share',
        logger  => $logger
    );
    cmp_deeply(
        $inventory,
        $tests{$test}->[1],
        "$test: inventory"
    );

}
