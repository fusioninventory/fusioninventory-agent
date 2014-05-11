#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'epson/AL-C1100.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C1100',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => '00:00:48:0d:be:cc',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-C1100',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C1100-0DBECC',
                MAC          => '00:00:48:0d:be:cc',
            },
            PAGECOUNTERS => {
                TOTAL      => '43065',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C1100 Hard Ver.1.00 Firm Ver.2.30',
                        IFDESCR          => 'AL-C1100 Hard Ver.1.00 Firm Ver.2.30',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:00:48:0d:be:cc',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '7216616',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1030873',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-C3900.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C3900',
            DESCRIPTION  => 'EPSON AL-C3900',

            SERIAL       => 'N5CZ102791',
            MAC          => '00:26:ab:9f:78:8b',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-C3900',
                COMMENTS     => 'EPSON AL-C3900',
                SERIAL       => 'N5CZ102791',
                MAC          => '00:26:ab:9f:78:8b',
            },
            CARTRIDGES => {
                TONERBLACK       => '20',
                TONERCYAN        => '45',
                TONERMAGENTA     => '23',
                TONERYELLOW      => '25',
            },
            PAGECOUNTERS => {
                TOTAL      => '7758',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10Base-T/100Base-TX/1000Base-T',
                        IFDESCR          => 'Ethernet 10Base-T/100Base-TX/1000Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:ab:9f:78:8b',
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
                        IFTYPE           => '24',
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
        },
    ],
    'epson/AL-C4200.1.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C4200',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            LOCATION     => 'Aff. Generales',
            UPTIME       => '(166086480) 19 days, 5:21:04.80',
            MEMORY       => '128',
            MAC          => '20:04:48:0e:d5:0e',
            IPS          => {
                IP => [
                    '172.17.3.81',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-0ED50E',
                LOCATION     => 'Aff. Generales',
                UPTIME       => '(166086480) 19 days, 5:21:04.80',
                MEMORY       => '128',
                MAC          => '20:04:48:0e:d5:0e',
                IPS          => {
                    IP => [
                        '172.17.3.81',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '73309',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.81',
                        MAC              => '20:04:48:0e:d5:0e',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3564032475',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '19488839',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-C4200.2.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C4200',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            LOCATION     => 'PPV - 2eme Etage',
            UPTIME       => '(17442921) 2 days, 0:27:09.21',
            MEMORY       => '128',
            MAC          => '00:00:48:d1:4b:c7',
            IPS          => {
                IP => [
                    '172.17.3.212',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                VENDOR       => 'Epson',
                MANUFACTURER => 'Epson',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D14BC7',
                LOCATION     => 'PPV - 2eme Etage',
                UPTIME       => '(17442921) 2 days, 0:27:09.21',
                MEMORY       => '128',
                MAC          => '00:00:48:d1:4b:c7',
                IPS          => {
                    IP => [
                        '172.17.3.212',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '60163',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.212',
                        MAC              => '00:00:48:d1:4b:c7',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '151879781',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1996995',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-C4200.3.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C4200',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            LOCATION     => 'PPV - 1er Etage',
            UPTIME       => '(311511314) 36 days, 1:18:33.14',
            MEMORY       => '128',
            MAC          => '00:00:48:d1:c3:0e',
            IPS          => {
                IP => [
                    '172.17.3.213',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D1C30E',
                LOCATION     => 'PPV - 1er Etage',
                UPTIME       => '(311511314) 36 days, 1:18:33.14',
                MEMORY       => '128',
                MAC          => '00:00:48:d1:c3:0e',
                IPS          => {
                    IP => [
                        '172.17.3.213',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '80918',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.213',
                        MAC              => '00:00:48:d1:c3:0e',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '2580632437',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '46784705',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-C4200.4.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-C4200',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-C4200-D362D2',
            UPTIME       => '(140436577) 16 days, 6:06:05.77',
            MEMORY       => '128',
            MAC          => '00:00:48:d3:62:d2',
            IPS          => {
                IP => [
                    '172.17.3.102',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D362D2',
                UPTIME       => '(140436577) 16 days, 6:06:05.77',
                MEMORY       => '128',
                MAC          => '00:00:48:d3:62:d2',
                IPS          => {
                    IP => [
                        '172.17.3.102',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '38054',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-C4200 Hard Ver.1.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.17.3.102',
                        MAC              => '00:00:48:d3:62:d2',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3110151478',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '4558450',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-M2400.1.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-M2400',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
                MAC          => '00:26:ab:7f:dd:af',
            },
            CARTRIDGES => {
                MAINTENANCEKIT   => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '319',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:ab:7f:dd:af',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '656509779',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '28072748',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'epson/AL-M2400.2.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Epson',
            VENDOR       => 'Epson',
            MODEL        => 'AL-M2400',
            DESCRIPTION  => 'EPSON Built-in 10Base-T/100Base-TX Print Server',

            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Epson',
                VENDOR       => 'Epson',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
                MAC          => '00:26:ab:7f:dd:af',
            },
            CARTRIDGES => {
                MAINTENANCEKIT   => '99',
            },
            PAGECOUNTERS => {
                TOTAL      => '1346',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFDESCR          => 'AL-M2400 Hard Ver.19.00 Firm Ver.2.40',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        MAC              => '00:26:ab:7f:dd:af',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '251210780',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '5941002',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
);

plan skip_all => 'SNMP walks database required'
    if !$ENV{SNMPWALK_DATABASE};
plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Agent::Logger->new(debug => 0);

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    my %discovery = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share',
        logger  => $logger
    );
    cmp_deeply(
        \%discovery,
        $tests{$test}->[0],
        "$test: discovery"
    );

    my $inventory = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share',
        logger  => $logger
    );
    cmp_deeply(
        $inventory,
        $tests{$test}->[1],
        "$test: inventory"
    );
}
