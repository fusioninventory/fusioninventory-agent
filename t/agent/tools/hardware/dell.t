#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'dell/M5200.1.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                UPTIME       => '(259620718) 30 days, 1:10:07.18',
                COMMENTS     => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
                MEMORY       => '64',
                NAME         => 'LXKE6E33E-2',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.13',
                    ],
                }
            },
            CARTRIDGES => {
                TONERBLACK       => '0',
                MAINTENANCEKIT   => '100',
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
                        MAC              => '00:00:00:00:00:00',
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
                        MAC              => '00:04:00:67:C7:7C',
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
        }
    ],
    'dell/M5200.2.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                UPTIME       => '(259655546) 30 days, 1:15:55.46',
                COMMENTS     => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
                MEMORY       => '64',
                NAME         => 'LXKB92115',
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
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3888',
                        MAC              => '00:00:00:00:00:00',
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
                        MAC              => '00:04:00:9D:84:A8',
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
        }
    ],
    'dell/unknown.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                UPTIME       => '(10346500) 1 day, 4:44:25.00',
                CONTACT      => 'Administrator',
                COMMENTS     => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
                MEMORY       => '0',
                NAME         => 'DEL0000f0aceaa9',
                IPS          => {
                    IP => [
                        '172.31.201.47',
                    ],
                },
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
                        MAC              => '00:00:F0:AC:EA:A9',
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
                        MAC              => '00:00:00:00:00:00',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '4726190',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '4726190',
                        IFOUTERRORS      => '0',
                    },
                ]
            }
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
        snmp       => $snmp,
        datadir    => './share'
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
