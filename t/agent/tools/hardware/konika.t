#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'konica/bizhub_C224.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => undef,
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

    my %device0 = getDeviceInfo($snmp, undef, './share');
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo($snmp, $dictionary, './share');
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
