#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'epson/AL-C4200.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => undef,
            MODELSNMP    => 'Printer0125',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106952'
        },
    ],
    'epson/AL-C4200.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => undef,
            MODELSNMP    => 'Printer0125',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106565'
        },
    ],
    'epson/AL-C4200.3.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => undef,
            MODELSNMP    => 'Printer0125',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106833'
        },
    ],
    'epson/AL-C4200.4.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => undef,
            MODELSNMP    => 'Printer0125',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ108184'
        },
    ],
    'epson/AL-C3900.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'epson/AL-C1100.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => undef,
        },
    ],
    'epson/AL-M2400.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef
        },
    ],
    'epson/AL-M2400.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef,
        },
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => 'resources/dictionary.xml'
);

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
    my %device0 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp
    );
    my %device1 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp, $dictionary
    );
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
