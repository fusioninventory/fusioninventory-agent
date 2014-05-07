#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'dell/M5200.1.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Lexmark',
            MODEL        => 'Dell Laser Printer M5200 9915DGL 551.014 --- Part Number ---',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',

            SNMPHOSTNAME => 'LXKE6E33E-2',
            SERIAL       => '9915DGL-46-13',
            UPTIME       => '(259620718) 30 days, 1:10:07.18',
            MEMORY       => '64',
            MAC          => '00:04:00:67:c7:7c',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.31.201.13',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Lexmark',
                MODEL        => 'Dell Laser Printer M5200 9915DGL 551.014 --- Part Number ---',
                COMMENTS     => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
                NAME         => 'LXKE6E33E-2',
                SERIAL       => '9915DGL-46-13',
                UPTIME       => '(259620718) 30 days, 1:10:07.18',
                MEMORY       => '64',
                MAC          => '00:04:00:67:c7:7c',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.13',
                    ],
                },
            },
            CARTRIDGES => {
                TONERBLACK       => '0',
                MAINTENANCEKIT   => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '146399',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3888',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '9350',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '9350',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.13',
                        MAC              => '00:04:00:67:c7:7c',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '908040492',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '22814217',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'dell/M5200.2.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Lexmark',
            MODEL        => 'Dell Laser Printer M5200 992B216 551.019 --- Part Number ---',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',

            SNMPHOSTNAME => 'LXKB92115',
            SERIAL       => '992B216-46-13',
            UPTIME       => '(259655546) 30 days, 1:15:55.46',
            MEMORY       => '64',
            MAC          => '00:04:00:9d:84:a8',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.31.201.52',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Lexmark',
                MODEL        => 'Dell Laser Printer M5200 992B216 551.019 --- Part Number ---',
                COMMENTS     => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
                NAME         => 'LXKB92115',
                SERIAL       => '992B216-46-13',
                UPTIME       => '(259655546) 30 days, 1:15:55.46',
                MEMORY       => '64',
                MAC          => '00:04:00:9d:84:a8',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.52',
                    ],
                },
            },
            CARTRIDGES => {
                TONERBLACK       => '0',
                MAINTENANCEKIT   => '100',
            },
            PAGECOUNTERS => {
                TOTAL      => '46925',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3888',
                        IP               => '127.0.0.1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3378',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '3378',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.52',
                        MAC              => '00:04:00:9d:84:a8',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '914666758',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '25587548',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        },
    ],
    'dell/unknown.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Hewlett-Packard',
            MODEL        => 'Dell 1600n',
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',

            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            CONTACT      => 'Administrator',
            UPTIME       => '(10346500) 1 day, 4:44:25.00',
            MEMORY       => '0',
            MAC          => '00:00:f0:ac:ea:a9',
            IPS          => {
                IP => [
                    '172.31.201.47',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'Dell 1600n',
                COMMENTS     => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
                NAME         => 'DEL0000f0aceaa9',
                CONTACT      => 'Administrator',
                UPTIME       => '(10346500) 1 day, 4:44:25.00',
                MEMORY       => '0',
                MAC          => '00:00:f0:ac:ea:a9',
                IPS          => {
                    IP => [
                        '172.31.201.47',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '140725',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'SEC NetOne Ethernet controller',
                        IFDESCR          => 'SEC NetOne Ethernet controller',
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.47',
                        MAC              => '00:00:f0:ac:ea:a9',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '74882867',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '5838888',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '6',
                        IFNAME           => 'pNA+ Loopback Driver',
                        IFDESCR          => 'pNA+ Loopback Driver',
                        IFTYPE           => '24',
                        IFSPEED          => '10000',
                        IFMTU            => '1536',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '4726190',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '4726190',
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
