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
    'tandberg/codec.walk' => [
        {
            MANUFACTURER => 'Tandberg',
            TYPE         => 'VIDEO',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9b:79',
        },
        {
            MANUFACTURER => 'Tandberg',
            TYPE         => 'VIDEO',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9b:79',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Tandberg',
                TYPE         => 'VIDEO',
                COMMENTS     => 'TANDBERG Codec',
                NAME         => 'VISIO.1',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth',
                        IFDESCR          => 'eth',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:60:02:9b:79',
                        IFLASTCHANGE     => '(20) 0:00:00.20',
                        IFINOCTETS       => '325377081',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '203169902',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16384',
                        IFLASTCHANGE     => '(19) 0:00:00.19',
                        IFINOCTETS       => '9350',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '9350',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Tandberg',
                TYPE         => 'VIDEO',
                COMMENTS     => 'TANDBERG Codec',
                NAME         => 'VISIO.1',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth',
                        IFDESCR          => 'eth',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:60:02:9b:79',
                        IFLASTCHANGE     => '(20) 0:00:00.20',
                        IFINOCTETS       => '325377081',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '203169902',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16384',
                        IFLASTCHANGE     => '(19) 0:00:00.19',
                        IFINOCTETS       => '9350',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '9350',
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
