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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                MODEL        => 'EPSON AL-C4200',
                LOCATION     => 'Aff. Generales',
                ID           => undef,
                SERIAL       => 'GMYZ106952',
                NAME         => 'AL-C4200-0ED50E'
            },
            PAGECOUNTERS => {
                TOTAL      => undef,
                PRINTTOTAL => undef,
                COPYTOTAL  => undef,
                COLOR      => undef,
                RECTOVERSO => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef
            },
            CARTRIDGES => {
                TONERCYAN    => 100,
                TONERYELLOW  => 84,
                TONERBLACK   => 45,
                TONERMAGENTA => 99
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '172.17.3.81',
                        MAC      => '',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNAME   => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFNUMBER => '1'
                    }
                ]
            },
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                MODEL        => 'EPSON AL-C4200',
                LOCATION     => 'PPV - 2eme Etage',
                ID           => undef,
                SERIAL       => 'GMYZ106565',
                NAME         => 'AL-C4200-D14BC7'
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                COLOR      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                PRINTBLACK => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef
            },
            CARTRIDGES => {
                TONERMAGENTA => 71,
                TONERBLACK   => 96,
                TONERCYAN    => 49,
                TONERYELLOW  => 98
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '172.17.3.212',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '',
                        IFNAME   => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFNUMBER => '1'
                    }
                ]
            },
        }
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
        {
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNAME   => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        MAC      => '',
                        IP       => '172.17.3.213'
                    }
                ]
            },
            CARTRIDGES => {
                TONERMAGENTA => 63,
                TONERCYAN    => 14,
                TONERBLACK   => 37,
                TONERYELLOW  => 46
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                TOTAL      => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                COLOR      => undef,
                PRINTTOTAL => undef
            },
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                NAME         => 'AL-C4200-D1C30E',
                SERIAL       => 'GMYZ106833',
                LOCATION     => 'PPV - 1er Etage',
                MODEL        => 'EPSON AL-C4200',
                ID           => undef,
            }
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MODEL        => 'EPSON AL-C4200',
                ID           => undef,
                SERIAL       => 'GMYZ108184',
                MEMORY       => 128,
                NAME         => 'AL-C4200-D362D2',
                LOCATION     => undef,
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '172.17.3.102',
                        MAC      => '',
                        IFNAME   => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    }
                ]
            },
            CARTRIDGES => {
                TONERCYAN    => 82,
                TONERMAGENTA => 65,
                TONERBLACK   => 32,
                TONERYELLOW  => 64
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                COPYCOLOR  => undef,
                COLOR      => undef,
                RECTOVERSO => undef,
                BLACK      => undef
            }
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
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
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => undef,
                ID           => undef,
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
    );
    cmp_deeply($device3, $tests{$test}->[2], $test);
}
