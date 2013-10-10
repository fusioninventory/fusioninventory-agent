#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'emc/Celerra.1.walk' => [
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'EMC',
                TYPE         => undef,
            },
        }
    ],
    'emc/Celerra.2.walk' => [
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'EMC',
                TYPE         => undef,
            },
        }
    ],
    'emc/CX3-10c.walk' => [
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'CX3-10c - Flare 3.26.0.10.5.032',
            SNMPHOSTNAME => 'BNK5RD1',
            MAC          => '00:60:16:1B:CD:7A',
        },
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'CX3-10c - Flare 3.26.0.10.5.032',
            SNMPHOSTNAME => 'BNK5RD1',
            MAC          => '00:60:16:1B:CD:7A',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'EMC',
                TYPE         => undef,
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
        snmp    => $snmp,
        datadir => './share'
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
