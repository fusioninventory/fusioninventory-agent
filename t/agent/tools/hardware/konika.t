#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub 421',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:aa:27:95:9e',
            SERIAL       => 'A0R6021004189',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.18.3.93',
                ],
            },
            UPTIME       => '(80180925) 9 days, 6:43:29.25',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                MAC          => '00:50:aa:27:95:9e',
                SERIAL       => 'A0R6021004189',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.93',
                    ],
                },
                UPTIME       => '(80180925) 9 days, 6:43:29.25',
            },
            PAGECOUNTERS => {
                TOTAL      => '463233',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.93',
                        MAC              => '00:50:aa:27:95:9e',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '856046914',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '185474174',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.93',
                    ],
                },
                UPTIME       => '(80180925) 9 days, 6:43:29.25',
            },
            PAGECOUNTERS => {
                TOTAL      => '463233',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.93',
                        MAC              => '00:50:aa:27:95:9e',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '856046914',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '185474174',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub 421',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:aa:27:96:68',
            SERIAL       => 'A0R6021004159',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.18.3.95',
                ],
            },
            UPTIME       => '(105584922) 12 days, 5:17:29.22',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                MAC          => '00:50:aa:27:96:68',
                SERIAL       => 'A0R6021004159',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.95',
                    ],
                },
                UPTIME       => '(105584922) 12 days, 5:17:29.22',
            },
            PAGECOUNTERS => {
                TOTAL      => '312526',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.95',
                        MAC              => '00:50:aa:27:96:68',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '928005361',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '71770611',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.95',
                    ],
                },
                UPTIME       => '(105584922) 12 days, 5:17:29.22',
            },
            PAGECOUNTERS => {
                TOTAL      => '312526',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.95',
                        MAC              => '00:50:aa:27:96:68',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '928005361',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '71770611',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub 421',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:aa:27:95:a3',
            SERIAL       => 'A0R6021004184',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.18.3.97',
                ],
            },
            UPTIME       => '(8072382) 22:25:23.82',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                MAC          => '00:50:aa:27:95:a3',
                SERIAL       => 'A0R6021004184',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.97',
                    ],
                },
                UPTIME       => '(8072382) 22:25:23.82',
            },
            PAGECOUNTERS => {
                TOTAL      => '473611',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.97',
                        MAC              => '00:50:aa:27:95:a3',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '71992551',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2314751',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub 421',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.18.3.97',
                    ],
                },
                UPTIME       => '(8072382) 22:25:23.82',
            },
            PAGECOUNTERS => {
                TOTAL      => '473611',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.18.3.97',
                        MAC              => '00:50:aa:27:95:a3',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '71992551',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2314751',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
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
    'konica/bizhub_C224.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub C224',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6b:8a:dc:ec',
            SERIAL       => 'A5C4021018159',
            MEMORY       => '0',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '192.168.200.18',
                ],
            },
            UPTIME       => '(17995666) 2 days, 1:59:16.66',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
                COMMENTS     => 'KONICA MINOLTA bizhub C224e',
                MAC          => '00:20:6b:8a:dc:ec',
                SERIAL       => 'A5C4021018159',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.200.18',
                    ],
                },
                UPTIME       => '(17995666) 2 days, 1:59:16.66',
            },
            CARTRIDGES => {
                TONERBLACK       => '94',
                TONERCYAN        => '97',
                TONERMAGENTA     => '98',
                TONERYELLOW      => '98',
                DRUMCYAN        => '99',
                DRUMMAGENTA     => '99',
                DRUMYELLOW      => '99',
            },
            PAGECOUNTERS => {
                TOTAL      => '2441',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.200.18',
                        MAC              => '00:20:6b:8a:dc:ec',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '34691067',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1294755',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1472',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1472',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
                COMMENTS     => 'KONICA MINOLTA bizhub C224e',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.200.18',
                    ],
                },
                UPTIME       => '(17995666) 2 days, 1:59:16.66',
            },
            CARTRIDGES => {
                TONERBLACK       => '94',
                TONERCYAN        => '97',
                TONERMAGENTA     => '98',
                TONERYELLOW      => '98',
                DRUMCYAN        => '99',
                DRUMMAGENTA     => '99',
                DRUMYELLOW      => '99',
            },
            PAGECOUNTERS => {
                TOTAL      => '2441',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.200.18',
                        MAC              => '00:20:6b:8a:dc:ec',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '34691067',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1294755',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1472',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1472',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'konica/bizhub_C224.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub C224',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6b:8a:dc:ec',
            SERIAL       => 'A5C4021018159',
            MEMORY       => '0',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '192.168.200.18',
                ],
            },
            UPTIME       => '(7570291) 21:01:42.91',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
                COMMENTS     => 'KONICA MINOLTA bizhub C224e',
                MAC          => '00:20:6b:8a:dc:ec',
                SERIAL       => 'A5C4021018159',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.200.18',
                    ],
                },
                UPTIME       => '(7570291) 21:01:42.91',
            },
            CARTRIDGES => {
                TONERBLACK       => '71',
                TONERCYAN        => '87',
                TONERMAGENTA     => '89',
                TONERYELLOW      => '90',
                DRUMCYAN        => '90',
                DRUMMAGENTA     => '90',
                DRUMYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL      => '11202',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.200.18',
                        MAC              => '00:20:6b:8a:dc:ec',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '121600165',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '5488983',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '2408',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2408',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
                COMMENTS     => 'KONICA MINOLTA bizhub C224e',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.200.18',
                    ],
                },
                UPTIME       => '(7570291) 21:01:42.91',
            },
            CARTRIDGES => {
                TONERBLACK       => '71',
                TONERCYAN        => '87',
                TONERMAGENTA     => '89',
                TONERYELLOW      => '90',
                DRUMCYAN        => '90',
                DRUMMAGENTA     => '90',
                DRUMYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL      => '11202',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.200.18',
                        MAC              => '00:20:6b:8a:dc:ec',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '121600165',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '5488983',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '2408',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2408',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'konica/bizhub_C554.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            MODEL        => 'bizhub C554',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C554e',
            MAC          => '00:20:6b:82:91:78',
            SERIAL       => 'A5AY021001363',
            MEMORY       => '0',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '192.168.150.26',
                ],
            },
            UPTIME       => '(43193657) 4 days, 23:58:56.57',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C554',
                COMMENTS     => 'KONICA MINOLTA bizhub C554e',
                MAC          => '00:20:6b:82:91:78',
                SERIAL       => 'A5AY021001363',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.150.26',
                    ],
                },
                UPTIME       => '(43193657) 4 days, 23:58:56.57',
            },
            CARTRIDGES => {
                TONERBLACK       => '96',
                TONERCYAN        => '80',
                TONERMAGENTA     => '85',
                TONERYELLOW      => '81',
                DRUMCYAN        => '94',
                DRUMMAGENTA     => '94',
                DRUMYELLOW      => '94',
            },
            PAGECOUNTERS => {
                TOTAL      => '32761',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.150.26',
                        MAC              => '00:20:6b:82:91:78',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '278301121',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '147959264',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1945',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1945',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C554',
                COMMENTS     => 'KONICA MINOLTA bizhub C554e',
                MEMORY       => '0',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '192.168.150.26',
                    ],
                },
                UPTIME       => '(43193657) 4 days, 23:58:56.57',
            },
            CARTRIDGES => {
                TONERBLACK       => '96',
                TONERCYAN        => '80',
                TONERMAGENTA     => '85',
                TONERYELLOW      => '81',
                DRUMCYAN        => '94',
                DRUMMAGENTA     => '94',
                DRUMYELLOW      => '94',
            },
            PAGECOUNTERS => {
                TOTAL      => '32761',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '192.168.150.26',
                        MAC              => '00:20:6b:82:91:78',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '278301121',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '147959264',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Software Loopback',
                        IFDESCR          => 'Software Loopback',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '16436',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1945',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1945',
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

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    my %discovery = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%discovery,
        $tests{$test}->[0],
        "$test: discovery"
    );

    my $inventory = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $inventory,
        $tests{$test}->[1],
        "$test: inventory"
    );

}
