#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'epson/AL-C4200.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => '20:04:48:0E:D5:0E',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => '20:04:48:0E:D5:0E',
            MODEL        => 'AL-C4200',
            MODELSNMP    => 'Printer0125',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106952'
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                MODEL        => 'AL-C4200',
                LOCATION     => 'Aff. Generales',
                ID           => undef,
                SERIAL       => 'GMYZ106952',
                NAME         => 'AL-C4200-0ED50E',
                UPTIME       => '(166086480) 19 days, 5:21:04.80'
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
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.81',
                        MAC              => '20:04:48:0E:D5:0E',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3564032475',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '19488839',
                        IFOUTERRORS      => '0',
                    }
                ]
            },
        }
    ],
    'epson/AL-C4200.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => '00:00:48:D1:4B:C7',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => '00:00:48:D1:4B:C7',
            MODELSNMP    => 'Printer0125',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106565',
            MODEL        => 'AL-C4200',
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                MODEL        => 'AL-C4200',
                LOCATION     => 'PPV - 2eme Etage',
                ID           => undef,
                SERIAL       => 'GMYZ106565',
                NAME         => 'AL-C4200-D14BC7',
                UPTIME       => '(17442921) 2 days, 0:27:09.21'
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
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.212',
                        MAC              => '00:00:48:D1:4B:C7',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '151879781',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1996995',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'epson/AL-C4200.3.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => '00:00:48:D1:C3:0E',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => '00:00:48:D1:C3:0E',
            MODEL        => 'AL-C4200',
            MODELSNMP    => 'Printer0125',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106833'
        },
        {
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.213',
                        MAC              => '00:00:48:D1:C3:0E',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '2580632437',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '46784705',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
            CARTRIDGES => {
                TONERMAGENTA => 63,
                TONERCYAN    => 14,
                TONERBLACK   => 37,
                TONERYELLOW  => 46
            },
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MEMORY       => 128,
                NAME         => 'AL-C4200-D1C30E',
                SERIAL       => 'GMYZ106833',
                LOCATION     => 'PPV - 1er Etage',
                MODEL        => 'AL-C4200',
                ID           => undef,
                UPTIME       => '(311511314) 36 days, 1:18:33.14'
            }
        }
    ],
    'epson/AL-C4200.4.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => '00:00:48:D3:62:D2',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => '00:00:48:D3:62:D2',
            MODEL        => 'AL-C4200',
            MODELSNMP    => 'Printer0125',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ108184'
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                MODEL        => 'AL-C4200',
                ID           => undef,
                SERIAL       => 'GMYZ108184',
                MEMORY       => 128,
                NAME         => 'AL-C4200-D362D2',
                UPTIME       => '(140436577) 16 days, 6:06:05.77'
            },
PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.102',
                        MAC              => '00:00:48:D3:62:D2',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3110151478',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '4558450',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
            CARTRIDGES => {
                TONERCYAN    => 82,
                TONERMAGENTA => 65,
                TONERBLACK   => 32,
                TONERYELLOW  => 64
            },
        }
    ],
    'epson/AL-C3900.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            MAC          => '00:26:AB:9F:78:8B',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            MAC          => '00:26:AB:9F:78:8B',
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                COMMENTS     => 'EPSON AL-C3900',
            },
PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10Base-T/100Base-TX/1000Base-T',
                        IFDESCR          => 'Ethernet 10Base-T/100Base-TX/1000Base-T',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:AB:9F:78:8B',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '2156405224',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '110909374',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'epson/AL-C1100.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => '00:00:48:0D:BE:CC',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => '00:00:48:0D:BE:CC',
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C1100-0DBECC',
            },
PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C1100 Hard Ver.1.00 Firm Ver.2.30',
                        IFDESCR          => 'AL-C1100 Hard Ver.1.00 Firm Ver.2.30',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:00:48:0D:BE:CC',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '7216616',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1030873',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'epson/AL-M2400.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:AB:7F:DD:AF'
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:AB:7F:DD:AF'
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:AB:7F:DD:AF',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '656509779',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '28072748',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'epson/AL-M2400.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:AB:7F:DD:AF',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:AB:7F:DD:AF',
        },
        {
            INFO => {
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:AB:7F:DD:AF',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '251210780',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '5941002',
                        IFOUTERRORS      => '0',
                    },
                ]
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
        snmp    => $snmp,
        dictionary => $dictionary,
        datadir => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
