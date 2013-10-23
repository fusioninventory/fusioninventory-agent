#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:9E',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
                UPTIME       => '(80180925) 9 days, 6:43:29.25',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:AA:27:95:9E',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:96:68',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
                UPTIME       => '(105584922) 12 days, 5:17:29.22',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:AA:27:96:68',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3',
            MODEL        => 'bizhub 421',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            MAC          => '00:50:AA:27:95:A3',
            MODEL        => 'bizhub 421',
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'bizhub 421',
                UPTIME       => '(8072382) 22:25:23.82',
                COMMENTS     => 'KONICA MINOLTA bizhub 421',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet 10/100/1000 Base-T',
                        IFDESCR          => 'Ethernet 10/100/1000 Base-T',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:50:AA:27:95:A3',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '0',
                        IFMTU            => '1536',
                        IFSTATUS         => 'up(1)',
                        IFINTERNALSTATUS => 'up(1)',
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
    'konica/bizhub_C224.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
            MODEL        => 'bizhub C224',
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub C224e',
            MAC          => '00:20:6B:8A:DC:EC',
            MODEL        => 'bizhub C224',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                MODEL        => 'bizhub C224',
                UPTIME       => '(17995666) 2 days, 1:59:16.66',
                COMMENTS     => 'KONICA MINOLTA bizhub C224e',
                MEMORY       => '0',
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
                        MAC              => '00:20:6B:8A:DC:EC',
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
