#!/usr/bin/perl

use strict;
use lib 't/lib';
use utf8;

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'sharp/MX_5001N.1.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'KENET - DPE2',
            MAC          => '00:22:F3:9D:1F:3B',
            MODEL        => 'MX-5001N',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'KENET - DPE2',
            MAC          => '00:22:F3:9D:1F:3B',
            MODEL        => 'MX-5001N',
            MODELSNMP    => 'Printer0578',
            FIRMWARE     => undef,
            SERIAL       => '9801405X00',
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-5001N',
                MODEL        => 'MX-5001N',
                ID           => undef,
                SERIAL       => '9801405X00',
                MEMORY       => 0,
                NAME         => 'KENET - DPE2',
                LOCATION     => 'RDC - apers escalier en bois',
                IPS          => {
                    IP => [
                        '172.31.201.114',
                    ],
                },
                UPTIME       => '(8649373) 1 day, 0:01:33.73'
            },
            CARTRIDGES => {
                DRUMYELLOW   => -4400,
                TONERCYAN    => 50,
                TONERBLACK   => 75,
                DRUMBLACK    => -2800,
                TONERMAGENTA => 50,
                DRUMMAGENTA  => -4400,
                DRUMCYAN     => -4400,
                TONERYELLOW  => 75,
                WASTETONER   => 0
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet',
                        IFDESCR          => 'Ethernet',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1514',
                        IP               => '172.31.201.114',
                        MAC              => '00:22:F3:9D:1F:3B',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '116703394',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '44812256',
                        IFOUTERRORS      => '141912',
                    },
                ]
            },
        }
    ],
    'sharp/MX_5001N.2.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'WASAI -- DFP',
            MAC          => '00:22:F3:9D:20:56',
            MODEL        => 'MX-5001N',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'WASAI -- DFP',
            MAC          => '00:22:F3:9D:20:56',
            MODEL        => 'MX-5001N',
            MODELSNMP    => 'Printer0578',
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-5001N',
                MODEL        => 'MX-5001N',
                NAME         => 'WASAI -- DFP',
                ID           => undef,
                LOCATION     => '1er etage couloir',
                IPS          => {
                    IP => [
                        '172.31.201.116',
                    ],
                },
                UPTIME       => '(28125680) 3 days, 6:07:36.80'
            },
PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet',
                        IFDESCR          => 'Ethernet',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1514',
                        IP               => '172.31.201.116',
                        MAC              => '00:22:F3:9D:20:56',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '216375141',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '38874951',
                        IFOUTERRORS      => '222292',
                    },
                ]
            },
        }
    ],
    'sharp/MX_5001N.3.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'MALAKA  - DOS -- IA-IPR',
            MAC          => '00:22:F3:9D:20:4B',
            MODEL        => 'MX-5001N',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'MALAKA  - DOS -- IA-IPR',
            MAC          => '00:22:F3:9D:20:4B',
            MODEL        => 'MX-5001N',
            MODELSNMP    => 'Printer0578',
            FIRMWARE     => undef,
            SERIAL       => '9801391X00',
        },
        {
            INFO => {
                COMMENTS     => 'SHARP MX-5001N',
                TYPE         => 'PRINTER',
                LOCATION     => 'Bat. Réhabilité ',
                NAME         => 'MALAKA  - DOS -- IA-IPR',
                SERIAL       => '9801391X00',
                MODEL        => 'MX-5001N',
                MEMORY       => 0,
                ID           => undef,
                MANUFACTURER => 'Sharp',
                IPS          => {
                    IP => [
                        '172.31.201.119',
                    ],
                },
                UPTIME       => '(1486295) 4:07:42.95'
            },
            CARTRIDGES => {
                DRUMCYAN     => -750,
                TONERCYAN    => 25,
                TONERBLACK   => 75,
                DRUMYELLOW   => -750,
                TONERYELLOW  => 25,
                DRUMMAGENTA  => -750,
                TONERMAGENTA => 25,
                DRUMBLACK    => -2200,
                WASTETONER   => 0
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet',
                        IFDESCR          => 'Ethernet',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1514',
                        IP               => '172.31.201.119',
                        MAC              => '00:22:F3:9D:20:4B',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '9667897',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1008700',
                        IFOUTERRORS      => '10674',
                    },
                ]
            },
        }
    ],
    'sharp/MX_2600N.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-2600N',
            SNMPHOSTNAME => 'PASTEK',
            MAC          => '00:22:F3:C8:04:99',
            MODEL        => 'MX-2600N',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-2600N',
            SNMPHOSTNAME => 'PASTEK',
            MAC          => '00:22:F3:C8:04:99',
            MODEL        => 'MX-2600N',
            MODELSNMP    => 'Printer0700',
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-2600N',
                ID           => undef,
                MODEL        => 'MX-2600N',
                LOCATION     => '2eme etage Bureau POTHIN',
                IPS          => {
                    IP => [
                        '172.31.201.123',
                    ],
                },
                UPTIME       => '(94252230) 10 days, 21:48:42.30'
            },
   PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Ethernet',
                        IFDESCR          => 'Ethernet',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1514',
                        IP               => '172.31.201.123',
                        MAC              => '00:22:F3:C8:04:99',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '891166577',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '577413631',
                        IFOUTERRORS      => '1444616',
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
