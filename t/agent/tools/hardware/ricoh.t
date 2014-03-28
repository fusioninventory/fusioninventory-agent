#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'ricoh/Aficio_AP3800C.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Ricoh',
            MODEL        => 'RICOH Aficio AP3800C',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',

            SNMPHOSTNAME => 'Aficio AP3800C',
            SERIAL       => 'P6011202081',
            UPTIME       => '(166369300) 19 days, 6:08:13.00',
            MEMORY       => '192',
            MAC          => '00:00:74:71:17:ca',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.20.3.63',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Ricoh',
                MODEL        => 'RICOH Aficio AP3800C',
                COMMENTS     => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio AP3800C',
                SERIAL       => 'P6011202081',
                UPTIME       => '(166369300) 19 days, 6:08:13.00',
                MEMORY       => '192',
                MAC          => '00:00:74:71:17:ca',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.20.3.63',
                    ],
                },
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
                TONERCYAN        => '100',
                TONERMAGENTA     => '100',
                TONERYELLOW      => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '754777',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'naf0',
                        IFDESCR          => 'naf0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.20.3.63',
                        MAC              => '00:00:74:71:17:ca',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(166369300) 19 days, 6:08:13.00',
                        IFINOCTETS       => '719798844',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '19582689',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '32976',
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
    'ricoh/Aficio_MP_C2050.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Ricoh',
            MODEL        => 'RICOH Aficio MP C2050',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',

            SNMPHOSTNAME => 'Aficio MP C2050',
            LOCATION     => 'Schoelcher - 1er',
            SERIAL       => 'V2294502833',
            UPTIME       => '(234064600) 27 days, 2:10:46.00',
            MEMORY       => '768',
            MAC          => '00:00:74:f8:ba:6f',
            IPS          => {
                IP => [
                    '0.0.0.0',
                    '10.75.14.27',
                    '127.0.0.1',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Ricoh',
                MODEL        => 'RICOH Aficio MP C2050',
                COMMENTS     => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio MP C2050',
                LOCATION     => 'Schoelcher - 1er',
                SERIAL       => 'V2294502833',
                UPTIME       => '(234064600) 27 days, 2:10:46.00',
                MEMORY       => '768',
                MAC          => '00:00:74:f8:ba:6f',
                IPS          => {
                    IP => [
                        '0.0.0.0',
                        '10.75.14.27',
                        '127.0.0.1',
                    ],
                },
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
                TONERCYAN        => '100',
                TONERMAGENTA     => '100',
                TONERYELLOW      => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '160668',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'ncmac0',
                        IFDESCR          => 'ncmac0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '10.75.14.27',
                        MAC              => '00:00:74:f8:ba:6f',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(234064600) 27 days, 2:10:46.00',
                        IFINOCTETS       => '1833974874',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '340367159',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '33196',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '7272',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '7272',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'ppp0',
                        IFDESCR          => 'ppp0',
                        IFTYPE           => '1',
                        IFSPEED          => '0',
                        IFMTU            => '1500',
                        IP               => '0.0.0.0',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '2',
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
    'ricoh/Aficio_SP_C420DN.1.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Ricoh',
            MODEL        => 'RICOH Aficio SP C420DN',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',

            SNMPHOSTNAME => 'Aficio SP C420DN',
            LOCATION     => 'Ugo',
            SERIAL       => 'S3899202523',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Ricoh',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
                SERIAL       => 'S3899202523',
                MAC          => '00:00:74:f3:01:95',
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
                TONERCYAN        => '100',
                TONERMAGENTA     => '100',
                TONERYELLOW      => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '53694',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'ncmac0',
                        IFDESCR          => 'ncmac0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:00:74:f3:01:95',
                        IFLASTCHANGE     => '(389591600) 45 days, 2:11:56.00',
                        IFINOCTETS       => '1800983311',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '87670165',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '33196',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '6412',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '6412',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'ppp0',
                        IFDESCR          => 'ppp0',
                        IFTYPE           => '1',
                        IFSPEED          => '0',
                        IFMTU            => '1500',
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
    'ricoh/Aficio_SP_C420DN.2.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Ricoh',
            MODEL        => 'RICOH Aficio SP C420DN',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',

            SNMPHOSTNAME => 'Aficio SP C420DN',
            LOCATION     => 'Ugo',
            SERIAL       => 'S3899202523',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Ricoh',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
                SERIAL       => 'S3899202523',
                MAC          => '00:00:74:f3:01:95',
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
                TONERCYAN        => '100',
                TONERMAGENTA     => '100',
                TONERYELLOW      => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '47295',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'ncmac0',
                        IFDESCR          => 'ncmac0',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:00:74:f3:01:95',
                        IFLASTCHANGE     => '(131508700) 15 days, 5:18:07.00',
                        IFINOCTETS       => '1761202969',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '104219046',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '0',
                        IFMTU            => '33196',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '6508',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '6508',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'ppp0',
                        IFDESCR          => 'ppp0',
                        IFTYPE           => '1',
                        IFSPEED          => '0',
                        IFMTU            => '1500',
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
