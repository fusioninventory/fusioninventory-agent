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
    'canon/LBP7660C_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon LBP7660C /P',
            SNMPHOSTNAME => 'LBP7660C',
            MAC          => '88:87:17:82:ca:b1',
        },
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon LBP7660C /P',
            SNMPHOSTNAME => 'LBP7660C',
            MAC          => '88:87:17:82:ca:b1',
            MODELSNMP    => 'Printer0790',
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                MODEL        => 'Canon LBP7660C',
                COMMENTS     => 'Canon LBP7660C /P',
                NAME         => 'LBP7660C',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '3950',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1500',
                        MAC              => '88:87:17:82:ca:b1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '996758063',
                        IFINERRORS       => '1',
                        IFOUTOCTETS      => '19122970',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                MODEL        => 'Canon LBP7660C',
                COMMENTS     => 'Canon LBP7660C /P',
                NAME         => 'LBP7660C',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '3950',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1500',
                        MAC              => '88:87:17:82:ca:b1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '996758063',
                        IFINERRORS       => '1',
                        IFOUTOCTETS      => '19122970',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'canon/MF4500_Series_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => '00:1e:8f:b0:9b:7d',
        },
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => '00:1e:8f:b0:9b:7d',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                MODEL        => 'Canon MF4500 Series',
                COMMENTS     => 'Canon MF4500 Series /P',
                NAME         => 'MF4500 Series',
            },
            PAGECOUNTERS => {
                TOTAL      => '659',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'FastEthernet',
                        IFDESCR          => 'FastEthernet',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:1e:8f:b0:9b:7d',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '1000000',
                        IFMTU            => '65535',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                MODEL        => 'Canon MF4500 Series',
                COMMENTS     => 'Canon MF4500 Series /P',
                NAME         => 'MF4500 Series',
            },
            PAGECOUNTERS => {
                TOTAL      => '659',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'FastEthernet',
                        IFDESCR          => 'FastEthernet',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:1e:8f:b0:9b:7d',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
                        IFSPEED          => '1000000',
                        IFMTU            => '65535',
                    },
                ]
            },
        }
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
