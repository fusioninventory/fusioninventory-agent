#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);
use XML::TreePP;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'd-link/DP_303.1.walk' => [
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5d:57:b3:c4',
        },
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5d:57:b3:c4',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'D-Link',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C4',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'D-Link',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C4',
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
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5d:57:b3:c7',
        },
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5d:57:b3:c7',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'D-Link',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C7',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'D-Link',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                COMMENTS     => 'D-Link DP-303 Print Server',
                NAME         => 'Print Server PS-57B3C7',
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
plan tests => 4 * scalar keys %tests;

my ($dictionary, $index);
if ($ENV{SNMPMODELS_DICTIONARY}) {
    $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => $ENV{SNMPMODELS_DICTIONARY}
    );
}
if ($ENV{SNMPMODELS_INDEX}) {
    $index = XML::TreePP->new()->parsefile($ENV{SNMPMODELS_INDEX});
}

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    # first test: discovery without dictionary
    my %device1 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%device1,
        $tests{$test}->[0],
        "$test: discovery, without dictionary"
    );

    # second test: discovery, with dictipnary
    SKIP: {
        skip "SNMP dictionary required, skipping", 1 unless $dictionary;

        my %device2 = getDeviceInfo(
            snmp       => $snmp,
            datadir    => './share',
            dictionary => $dictionary,
        );
        cmp_deeply(
            \%device2,
            $tests{$test}->[1],
            "$test: discovery, with dictionary"
        );
    };

    # third test: inventory without model
    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $device3,
        $tests{$test}->[2],
        "$test: inventory, without model"
    );

    # fourth test: inventory, with model
    SKIP: {
        my $model_id = $tests{$test}->[1]->{MODELSNMP};
        skip "SNMP models index required, skipping", 1 unless $index;
        skip "No model associated, skipping", 1 unless $model_id;
        my $model = loadModel($index->{$model_id});

        my $device4 = getDeviceFullInfo(
            snmp    => $snmp,
            datadir => './share',
            model   => $model
        );
        cmp_deeply(
            $device4,
            $tests{$test}->[3],
            "$test: inventory, with model"
        );
    };
}
