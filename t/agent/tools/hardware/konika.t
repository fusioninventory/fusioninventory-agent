#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep;
use YAML qw(LoadFile);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Test::Utils;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                COLOR      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                COLOR      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                COLOR      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} elsif (!$ENV{SNMPMODEL_DATABASE}) {
    plan skip_all => 'SNMP models database required';
} else {
    plan tests => 3 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
);

my $index = LoadFile("$ENV{SNMPMODEL_DATABASE}/index.yaml");

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my %device0 = getDeviceInfo($snmp);
    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);

    my $model_id = $tests{$test}->[1]->{MODELSNMP};
    my $model = $model_id ?
        loadModel("$ENV{SNMPMODEL_DATABASE}/$index->{$model_id}") : undef;

    my $device3 = FusionInventory::Agent::Tools::Hardware::getDeviceFullInfo(
        snmp  => $snmp,
        model => $model,
        device => {
            FILE => "$ENV{SNMPWALK_DATABASE}/$test",
            TYPE => 'PRINTER',
        },
    );
    cmp_deeply($device3, $tests{$test}->[2], $test);
}
