#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'dell/M5200.1.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'dell/M5200.2.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'dell/unknown.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PORTS => {
                PORT => []
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
