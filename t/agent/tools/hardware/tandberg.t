#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'tandberg/codec.walk' => [
        {
            MANUFACTURER => 'Tandberg',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9B:79',
        },
        {
            MANUFACTURER => 'Tandberg',
            DESCRIPTION  => 'TANDBERG Codec',
            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9B:79',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Tandberg',
                TYPE         => undef,
                COMMENTS     => 'TANDBERG Codec',
                NAME         => 'VISIO.1',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth',
                        IFDESCR          => 'eth',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:60:02:9B:79',
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
                        IFTYPE           => 'softwareLoopback(24)',
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
        }
    ],
);

setPlan(scalar keys %tests);

my $dictionary = getDictionnary();
my $index      = getIndex();

foreach my $test (sort keys %tests) {
    my $snmp  = getSNMP($test);
    my $model = getModel($index, $tests{$test}->[1]->{MODELSNMP});

    my %device0 = getDeviceInfo($snmp);
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp  => $snmp,
        model => $model,
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
