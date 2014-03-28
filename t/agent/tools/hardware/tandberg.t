#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'tandberg/codec.walk' => [
        {
            TYPE         => 'VIDEO',
            MANUFACTURER => 'Tandberg',
            DESCRIPTION  => 'TANDBERG Codec',

            SNMPHOSTNAME => 'VISIO.1',
            MAC          => '00:50:60:02:9b:79',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'VIDEO',
                MANUFACTURER => 'Tandberg',
                COMMENTS     => 'TANDBERG Codec',
                NAME         => 'VISIO.1',
                MAC          => '00:50:60:02:9b:79',
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
        $tests{$test}->[1],
        "$test: inventory"
    );
}
