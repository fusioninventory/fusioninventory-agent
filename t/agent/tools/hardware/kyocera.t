#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep;
use YAML qw(LoadFile);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Utils;

my %tests = (
    'kyocera/TASKalfa-820.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                COLOR      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'kyocera/TASKalfa-181.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                COLOR      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'kyocera/FS-2000D.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
            MODELSNMP    => 'Printer0351',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21506',
        },
        {
            INFO => {
                SERIAL       => 'XLM7Y21506',
                ID           => undef,
                COMMENTS     => 'KYOCERA MITA Printing System',
                MODEL        => 'FS-2000D',
                MANUFACTURER => 'Kyocera',
                LOCATION     => undef,
                MEMORY       => 0,
                NAME         => undef,
                TYPE         => 'PRINTER'
            },
            CARTRIDGES => {
                WASTETONER => 100,
                TONERBLACK => 75
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                COLOR      => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                TOTAL      => undef,
                PRINTCOLOR => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'eth0',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '',
                        IFNUMBER => '1',
                        IP       => '172.20.3.51'
                    }
                ]
            }
        }
    ],
    'kyocera/FS-2000D.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
            MODELSNMP    => 'Printer0351',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21503',
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                COMMENTS     => 'KYOCERA MITA Printing System',
                NAME         => undef,
                SERIAL       => 'XLM7Y21503',
                MODEL        => 'FS-2000D',
                LOCATION     => undef,
                ID           => undef,
                MEMORY       => 0
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                COLOR      => undef
            },
            CARTRIDGES  => {
                TONERBLACK => 37,
                WASTETONER => 100
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'eth0',
                        IP       => '172.20.3.4',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNUMBER => '1',
                        MAC      => ''
                    }
                ]
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
        device => {
            FILE => "$ENV{SNMPWALK_DATABASE}/$test",
            TYPE => 'PRINTER',
        },
        model => $model
    );
    cmp_deeply($device3, $tests{$test}->[2], $test);
}
