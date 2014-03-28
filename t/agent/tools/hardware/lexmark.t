#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'lexmark/T622.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Lexmark',
            MODEL        => 'Lexmark T622 41XT225  543.006',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',

            SNMPHOSTNAME => 'LXK3936A4',
            UPTIME       => '(256604241) 29 days, 16:47:22.41',
            MEMORY       => '32',
            MAC          => '00:04:00:9c:6c:25',
            IPS          => {
                IP => [
                    '127.0.0.1',
                    '172.31.201.21',
                ],
            },
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Lexmark',
                MODEL        => 'Lexmark T622 41XT225  543.006',
                COMMENTS     => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
                NAME         => 'LXK3936A4',
                UPTIME       => '(256604241) 29 days, 16:47:22.41',
                MEMORY       => '32',
                MAC          => '00:04:00:9c:6c:25',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.31.201.21',
                    ],
                },
            },
            PAGECOUNTERS => {
                TOTAL      => '68116',
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
                        MAC              => '00:04:00:9c:6c:25',
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
        },
    ],
    'lexmark/X792.walk' => [
        {
            TYPE         => 'PRINTER',
            MANUFACTURER => 'Lexmark',
            MODEL        => 'X792',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',

            SNMPHOSTNAME => 'ET0021B7427721',
            SERIAL       => '7562029401523-96-0',
            MAC          => '00:21:b7:42:77:21',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Lexmark',
                MODEL        => 'X792',
                COMMENTS     => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
                NAME         => 'ET0021B7427721',
                SERIAL       => '7562029401523-96-0',
                MAC          => '00:21:b7:42:77:21',
            },
            CARTRIDGES => {
                TONERBLACK       => '90',
                TONERCYAN        => '90',
                TONERMAGENTA     => '90',
                TONERYELLOW      => '90',
            },
            PAGECOUNTERS => {
                TOTAL      => '25292',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'lo',
                        IFDESCR          => 'lo',
                        IFTYPE           => '24',
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
                        IFTYPE           => '6',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:21:b7:42:77:21',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '436783447',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '51509126',
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
