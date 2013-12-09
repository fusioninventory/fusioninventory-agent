#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'epson/AL-C1100.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => '00:00:48:0d:be:cc',
            MODEL        => 'AL-C1100',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => '00:00:48:0d:be:cc',
            MODEL        => 'AL-C1100',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C1100',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C1100-0DBECC',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C1100',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C1100-0DBECC',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            MAC          => '00:26:ab:9f:78:8b',
            MODEL        => 'AL-C3900',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            MAC          => '00:26:ab:9f:78:8b',
            MODEL        => 'AL-C3900',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C3900',
                COMMENTS     => 'EPSON AL-C3900',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C3900',
                COMMENTS     => 'EPSON AL-C3900',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => '20:04:48:0e:d5:0e',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => '20:04:48:0e:d5:0e',
            MODELSNMP    => 'Printer0125',
            MODEL        => 'AL-C4200',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106952',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-0ED50E',
                MEMORY       => '128',
                LOCATION     => 'Aff. Generales',
                IPS          => {
                    IP => [
                        '172.17.3.81',
                    ],
                },
                UPTIME       => '(166086480) 19 days, 5:21:04.80',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-0ED50E',
                MEMORY       => '128',
                LOCATION     => 'Aff. Generales',
                SERIAL       => 'GMYZ106952',
                IPS          => {
                    IP => [
                        '172.17.3.81',
                    ],
                },
                UPTIME       => '(166086480) 19 days, 5:21:04.80',
            },
            CARTRIDGES => {
                TONERBLACK       => '45',
                TONERCYAN        => '100',
                TONERMAGENTA     => '99',
                TONERYELLOW      => '84',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => '00:00:48:d1:4b:c7',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => '00:00:48:d1:4b:c7',
            MODELSNMP    => 'Printer0125',
            MODEL        => 'AL-C4200',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106565',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D14BC7',
                MEMORY       => '128',
                LOCATION     => 'PPV - 2eme Etage',
                IPS          => {
                    IP => [
                        '172.17.3.212',
                    ],
                },
                UPTIME       => '(17442921) 2 days, 0:27:09.21',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D14BC7',
                MEMORY       => '128',
                LOCATION     => 'PPV - 2eme Etage',
                SERIAL       => 'GMYZ106565',
                IPS          => {
                    IP => [
                        '172.17.3.212',
                    ],
                },
                UPTIME       => '(17442921) 2 days, 0:27:09.21',
            },
            CARTRIDGES => {
                TONERBLACK       => '96',
                TONERCYAN        => '49',
                TONERMAGENTA     => '71',
                TONERYELLOW      => '98',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => '00:00:48:d1:c3:0e',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => '00:00:48:d1:c3:0e',
            MODELSNMP    => 'Printer0125',
            MODEL        => 'AL-C4200',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ106833',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D1C30E',
                MEMORY       => '128',
                LOCATION     => 'PPV - 1er Etage',
                IPS          => {
                    IP => [
                        '172.17.3.213',
                    ],
                },
                UPTIME       => '(311511314) 36 days, 1:18:33.14',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D1C30E',
                MEMORY       => '128',
                LOCATION     => 'PPV - 1er Etage',
                SERIAL       => 'GMYZ106833',
                IPS          => {
                    IP => [
                        '172.17.3.213',
                    ],
                },
                UPTIME       => '(311511314) 36 days, 1:18:33.14',
            },
            CARTRIDGES => {
                TONERBLACK       => '37',
                TONERCYAN        => '14',
                TONERMAGENTA     => '63',
                TONERYELLOW      => '46',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => '00:00:48:d3:62:d2',
            MODEL        => 'AL-C4200',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => '00:00:48:d3:62:d2',
            MODELSNMP    => 'Printer0125',
            MODEL        => 'AL-C4200',
            FIRMWARE     => undef,
            SERIAL       => 'GMYZ108184',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D362D2',
                MEMORY       => '128',
                IPS          => {
                    IP => [
                        '172.17.3.102',
                    ],
                },
                UPTIME       => '(140436577) 16 days, 6:06:05.77',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-C4200',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-C4200-D362D2',
                MEMORY       => '128',
                SERIAL       => 'GMYZ108184',
                IPS          => {
                    IP => [
                        '172.17.3.102',
                    ],
                },
                UPTIME       => '(140436577) 16 days, 6:06:05.77',
            },
            CARTRIDGES => {
                TONERBLACK       => '32',
                TONERCYAN        => '82',
                TONERMAGENTA     => '65',
                TONERYELLOW      => '64',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
            MODEL        => 'AL-M2400',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
            MODEL        => 'AL-M2400',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
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
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
            MODEL        => 'AL-M2400',
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => '00:26:ab:7f:dd:af',
            MODEL        => 'AL-M2400',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Epson',
                TYPE         => 'PRINTER',
                MODEL        => 'AL-M2400',
                COMMENTS     => 'EPSON Built-in 10Base-T/100Base-TX Print Server',
                NAME         => 'AL-M2400-7FDDAF',
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
plan tests => 4 * scalar keys %tests;

my ($dictionary, $index);
if ($ENV{SNMPMODELS_DICTIONARY}) {
    $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => $ENV{SNMPMODELS_DICTIONARY}
    );
}
if ($ENV{SNMPMODELS_INDEX}) {
    $index = XML::TreePP->new()->parsefile($ENV{SNMPMODELS_INDEX});
}

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    # first test: discovery without dictionary
    my %device1 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%device1,
        $tests{$test}->[0],
        "$test: discovery, without dictionary"
    );

    # second test: discovery, with dictipnary
    SKIP: {
        skip "SNMP dictionary required, skipping", 1 unless $dictionary;

        my %device2 = getDeviceInfo(
            snmp       => $snmp,
            datadir    => './share',
            dictionary => $dictionary,
        );
        cmp_deeply(
            \%device2,
            $tests{$test}->[1],
            "$test: discovery, with dictionary"
        );
    };

    # third test: inventory without model
    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $device3,
        $tests{$test}->[2],
        "$test: inventory, without model"
    );

    # fourth test: inventory, with model
    SKIP: {
        my $model_id = $tests{$test}->[1]->{MODELSNMP};
        skip "SNMP models index required, skipping", 1 unless $index;
        skip "No model associated, skipping", 1 unless $model_id;
        my $model = loadModel($index->{$model_id});

        my $device4 = getDeviceFullInfo(
            snmp    => $snmp,
            datadir => './share',
            model   => $model
        );
        cmp_deeply(
            $device4,
            $tests{$test}->[3],
            "$test: inventory, with model"
        );
    };
}
