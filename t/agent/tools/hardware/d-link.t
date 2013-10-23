#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'd-link/DP_303.1.walk' => [
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5D:57:B3:C4'
        },
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5D:57:B3:C4'
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
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1518',
                        MAC              => '00:05:5D:57:B3:C4',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3313005088',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '124761128',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'd-link/DP_303.2.walk' => [
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5D:57:B3:C7'
        },
        {
            MANUFACTURER => 'D-Link',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5D:57:B3:C7'
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
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1518',
                        MAC              => '00:05:5D:57:B3:C7',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '13974939',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '301006',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
);

setPlan(scalar keys %tests);

my $dictionary = getDictionnary();
my $index      = getIndex();

foreach my $test (sort keys %tests) {
    my $snmp  = getSNMP($test);
    my $model = getModel($index, $tests{$test}->[1]->{MODELSNMP});

    my %device0 = getDeviceInfo(
        snmp       => $snmp,
        datadir    => './share'
    );
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo(
        snmp       => $snmp,
        dictionary => $dictionary,
        datadir    => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
