#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'lexmark/T622.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXK3936A4',
            MAC          => '00:04:00:9C:6C:25',
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXK3936A4',
            MAC          => '00:04:00:9C:6C:25',
            MODELSNMP    => 'Printer0643',
            FIRMWARE     => undef,
            SERIAL       => 'LXK3936A4'
        },
        {
            INFO => {
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
                MEMORY       => 32,
                ID           => undef,
                NAME         => 'LXK3936A4',
                MODEL        => 'Lexmark T622 41XT225  543.006',
                SERIAL       => 'LXK3936A4',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.21',
                    ],
                },
                UPTIME       => '(256604241) 29 days, 16:47:22.41'
            },
            CARTRIDGES => {
                TONERBLACK => 100
            },
            PAGECOUNTERS => {
                TOTAL => '68116',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo0',
                        IFDESCR          => 'lo0',
                        IFTYPE           => '24',
                        IFSPEED          => '10000000',
                        IFMTU            => '3904',
                        IP               => '127.0.0.1',
                        MAC              => '00:00:00:00:00:00',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '174',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '174',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => '6',
                        IFSPEED          => '10000000',
                        IFMTU            => '1500',
                        IP               => '172.31.201.21',
                        MAC              => '00:04:00:9C:6C:25',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '883395992',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2404715',
                        IFOUTERRORS      => '0',
                    },
                ]
            },
        }
    ],
    'lexmark/X792.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => '00:21:B7:42:77:21',
            MODEL        => 'X792',
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => '00:21:B7:42:77:21',
            MODEL        => 'X792',
        },
        {
            INFO => {
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'X792',
                COMMENTS     => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
                NAME         => 'ET0021B7427721',
            },
            CARTRIDGES => {
                TONERBLACK       => '90',
                TONERCYAN        => '90',
                TONERMAGENTA     => '90',
                TONERYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL => '25292',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '10000000',
                        IFMTU            => '16436',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '526887060',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '526887060',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'eth0',
                        IFDESCR          => 'eth0',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:21:B7:42:77:21',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '436783447',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '51509126',
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
