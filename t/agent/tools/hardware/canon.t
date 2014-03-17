#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
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
plan tests => 2 * scalar keys %tests;

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    my %discovery = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%discovery,
        $tests{$test}->[0],
        "$test: discovery"
    );

    my $inventory = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $inventory,
        $tests{$test}->[2],
        "$test: inventory"
    );
}
