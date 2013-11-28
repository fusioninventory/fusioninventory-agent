#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'kyocera/F-5350DN.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:ca:dd',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:ca:dd',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'FS-C5350DN',
                COMMENTS     => 'KYOCERA MITA Printing System',
                IPS          => {
                    IP => [
                        '128.93.22.16',
                    ],
                },
                UPTIME       => '(55544038) 6 days, 10:17:20.38',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '66867',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lnPci0',
                        IFDESCR          => 'lnPci0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '128.93.22.16',
                        MAC              => '00:c0:ee:80:ca:dd',
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
        }
    ],
    'kyocera/F-5350DN.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:73:71',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:73:71',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'FS-C5350DN',
                COMMENTS     => 'KYOCERA MITA Printing System',
                IPS          => {
                    IP => [
                        '128.93.22.52',
                    ],
                },
                UPTIME       => '(44432286) 5 days, 3:25:22.86',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '59608',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lnPci0',
                        IFDESCR          => 'lnPci0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '128.93.22.52',
                        MAC              => '00:c0:ee:80:73:71',
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
        }
    ],
    'kyocera/F-5350DN.3.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:73:6c',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:c0:ee:80:73:6c',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'FS-C5350DN',
                COMMENTS     => 'KYOCERA MITA Printing System',
                IPS          => {
                    IP => [
                        '128.93.22.70',
                    ],
                },
                UPTIME       => '(3145468) 8:44:14.68',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '71686',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lnPci0',
                        IFDESCR          => 'lnPci0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '128.93.22.70',
                        MAC              => '00:c0:ee:80:73:6c',
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
        }
    ],
    'kyocera/FS-2000D.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            MAC          => '00:c0:ee:6a:96:dd',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            MAC          => '00:c0:ee:6a:96:dd',
            MODELSNMP    => 'Printer0351',
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21506',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'FS-2000D',
                COMMENTS     => 'KYOCERA MITA Printing System',
                MEMORY       => '0',
                SERIAL       => 'XLM7Y21506',
                IPS          => {
                    IP => [
                        '172.20.3.51',
                    ],
                },
                UPTIME       => '(19416556) 2 days, 5:56:05.56',
            },
            CARTRIDGES => {
                TONERBLACK       => '75',
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '72657',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1514',
                        IP               => '172.20.3.51',
                        MAC              => '00:c0:ee:6a:96:dd',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                    },
                ]
            },
        }
    ],
    'kyocera/FS-2000D.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            MAC          => '00:c0:ee:6a:97:07',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            MAC          => '00:c0:ee:6a:97:07',
            MODELSNMP    => 'Printer0351',
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21503',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'FS-2000D',
                COMMENTS     => 'KYOCERA MITA Printing System',
                MEMORY       => '0',
                SERIAL       => 'XLM7Y21503',
                IPS          => {
                    IP => [
                        '172.20.3.4',
                    ],
                },
                UPTIME       => '(749216) 2:04:52.16',
            },
            CARTRIDGES => {
                TONERBLACK       => '37',
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '13300',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1514',
                        IP               => '172.20.3.4',
                        MAC              => '00:c0:ee:6a:97:07',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                    },
                ]
            },
        }
    ],
    'kyocera/TASKalfa-181.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            MAC          => '00:c0:ee:2f:0d:d9',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            MAC          => '00:c0:ee:2f:0d:d9',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'CD 1218_DC 2218',
                COMMENTS     => 'KYOCERA MITA Printing System',
                IPS          => {
                    IP => [
                        '172.20.3.38',
                    ],
                },
                UPTIME       => '(17673056) 2 days, 1:05:30.56',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '20100',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1514',
                        IP               => '172.20.3.38',
                        MAC              => '00:c0:ee:2f:0d:d9',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                    },
                ]
            },
        }
    ],
    'kyocera/TASKalfa-820.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            MAC          => '00:c0:ee:31:84:6b',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            MAC          => '00:c0:ee:31:84:6b',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                MODEL        => 'CD 1182_DC 2182',
                COMMENTS     => 'KYOCERA MITA Printing System',
                IPS          => {
                    IP => [
                        '172.20.3.24',
                    ],
                },
                UPTIME       => '(11310876) 1 day, 7:25:08.76',
            },
            CARTRIDGES => {
                WASTETONER       => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '561540',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1514',
                        IP               => '172.20.3.24',
                        MAC              => '00:c0:ee:31:84:6b',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                    },
                ]
            },
        }
    ],
    'kyocera/utax_ta.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'UTAX_TA Printing System',
            MAC          => '00:c0:ee:80:dd:2d',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'UTAX_TA Printing System',
            MAC          => '00:c0:ee:80:dd:2d',
            MODELSNMP    => 'Networking2073',
            FIRMWARE     => undef,
            SERIAL       => 'Q250Z01068',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                COMMENTS     => 'UTAX_TA Printing System',
                SERIAL       => 'Q250Z01068',
                IPS          => {
                    IP => [
                        '10.104.154.211',
                    ],
                },
                UPTIME       => '(281437) 0:46:54.37',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '10.104.154.211',
                        MAC              => '00:c0:ee:80:dd:2d',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '25318524',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '18480',
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
        snmp       => $snmp,
        dictionary => $dictionary,
        datadir    => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
