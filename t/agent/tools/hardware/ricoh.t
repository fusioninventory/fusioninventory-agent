#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'ricoh/Aficio_AP3800C.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => '00:00:74:71:17:CA'
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => '00:00:74:71:17:CA',
        },
        {
            INFO => {
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'ricoh/Aficio_MP_C2050.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:F8:BA:6F',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:F8:BA:6F',
            MODELSNMP    => 'Printer0522',
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                COMMENTS     => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
                MEMORY       => 768,
                LOCATION     => 'Schoelcher - 1er',
                ID           => undef,
                MODEL        => undef,
            },
            CARTRIDGES => {
                TONERMAGENTA => 100,
                TONERCYAN    => 100,
                TONERBLACK   => 100,
                WASTETONER   => 100,
                TONERYELLOW  => 100
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '10.75.14.27',
                        MAC      => '00:00:74:F8:BA:6F',
                        IFNAME   => 'ncmac0',
                        IFTYPE   => '6',
                        IFNUMBER => '1'
                    },
                    {
                        IP       => '127.0.0.1',
                        IFNAME   => 'lo0',
                        IFTYPE   => '24',
                        IFNUMBER => '2'
                    },
                    {
                        IFTYPE => '1',
                        IFNAME => 'ppp0',
                        IP => '0.0.0.0',
                        IFNUMBER => '3'
                    }
                ]
            },
        }
    ],
    'ricoh/Aficio_SP_C420DN.1.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:F3:01:95',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:F3:01:95',
        },
        {
            INFO => {
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'ricoh/Aficio_SP_C420DN.2.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:F3:01:95'
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:F3:01:95'
        },
        {
            INFO => {
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                ID           => undef,
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
