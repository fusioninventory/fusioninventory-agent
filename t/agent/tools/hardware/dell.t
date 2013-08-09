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
    'dell/M5200.1.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef
            }
        }
    ],
    'dell/M5200.2.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef
            }
        }
    ],
    'dell/unknown.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef
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
