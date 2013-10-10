#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'emc/Celerra.1.walk' => [
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'EMC',
                TYPE         => undef,
                COMMENTS     => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
                CONTACT      => 'nasadmin',
                NAME         => 'server_2',
                LOCATION     => 'here',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'mge0',
                        IFDESCR          => 'mge0',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '100000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:2C:49:EA',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1389411904',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '162095884',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'mge1',
                        IFDESCR          => 'mge1',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '100000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:2C:49:E8',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '1933542956',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2543359608',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'cge0',
                        IFDESCR          => 'cge0',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:08',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '3247987180',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2794180238',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '4',
                        IFNAME           => 'cge1',
                        IFDESCR          => 'cge1',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:09',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '5',
                        IFNAME           => 'cge2',
                        IFDESCR          => 'cge2',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:02',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '6',
                        IFNAME           => 'cge3',
                        IFDESCR          => 'cge3',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:03',
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
    'emc/Celerra.2.walk' => [
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            MANUFACTURER => 'EMC',
            DESCRIPTION  => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
            SNMPHOSTNAME => 'server_2',
            MAC          => '00:60:16:26:8A:02',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'EMC',
                TYPE         => undef,
                COMMENTS     => 'Product: EMC Celerra File Server   Project: SNAS   Version: T5.6.52.201',
                CONTACT      => 'nasadmin',
                NAME         => 'server_2',
                LOCATION     => 'here',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'mge0',
                        IFDESCR          => 'mge0',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '100000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:2C:49:EA',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '865314776',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '3263374717',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'mge1',
                        IFDESCR          => 'mge1',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '100000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:2C:49:E8',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '423286895',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '68857096',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'cge0',
                        IFDESCR          => 'cge0',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:08',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '588172446',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '57147036',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '4',
                        IFNAME           => 'cge1',
                        IFDESCR          => 'cge1',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:09',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '5',
                        IFNAME           => 'cge2',
                        IFDESCR          => 'cge2',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:02',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '6',
                        IFNAME           => 'cge3',
                        IFDESCR          => 'cge3',
                        IFTYPE           => 'iso88023Csmacd(7)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '9000',
                        MAC              => '00:60:16:26:8A:03',
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
    'emc/CX3-10c.walk' => [
        {
            DESCRIPTION  => 'CX3-10c - Flare 3.26.0.10.5.032',
            SNMPHOSTNAME => 'BNK5RD1',
            MAC          => '00:60:16:1B:CD:7A',
        },
        {
            DESCRIPTION  => 'CX3-10c - Flare 3.26.0.10.5.032',
            SNMPHOSTNAME => 'BNK5RD1',
            MAC          => '00:60:16:1B:CD:7A',
        },
        {
            INFO => {
                ID           => undef,
                TYPE         => undef,
                COMMENTS     => 'CX3-10c - Flare 3.26.0.10.5.032',
                NAME         => 'BNK5RD1',
                UPTIME       => '(2246605893) 260 days, 0:34:18.93',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'Internal loopback interface for 127.0.0 network',
                        IFDESCR          => 'Internal loopback interface for 127.0.0 network',
                        IFTYPE           => 'softwareLoopback(24)',
                        IFSPEED          => '10000000',
                        IFMTU            => '32768',
                        IFSTATUS         => 'dormant(5)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '2',
                        IFNAME           => 'Broadcom NetXtreme Gigabit Ethernet #2 - Packet Scheduler Miniport.',
                        IFDESCR          => 'Broadcom NetXtreme Gigabit Ethernet #2 - Packet Scheduler Miniport.',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:60:16:1E:56:F7',
                        IFSTATUS         => 'dormant(5)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(3029065326) 350 days, 14:04:13.26',
                        IFINOCTETS       => '483',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '400165',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '3',
                        IFNAME           => 'Broadcom NetXtreme Gigabit Ethernet - Packet Scheduler Miniport.',
                        IFDESCR          => 'Broadcom NetXtreme Gigabit Ethernet - Packet Scheduler Miniport.',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '100000000',
                        IFMTU            => '1500',
                        MAC              => '00:60:16:1E:56:F6',
                        IFSTATUS         => 'dormant(5)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(3029065326) 350 days, 14:04:13.26',
                        IFINOCTETS       => '2770054393',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '619077385',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '4',
                        IFNAME           => 'QLogic 1Gb PCI Ethernet Adapter #2 - Packet Scheduler Miniport.',
                        IFDESCR          => 'QLogic 1Gb PCI Ethernet Adapter #2 - Packet Scheduler Miniport.',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1500',
                        MAC              => '00:60:16:1B:CD:7E',
                        IFSTATUS         => 'dormant(5)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(3029065326) 350 days, 14:04:13.26',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '5',
                        IFNAME           => 'QLogic 1Gb PCI Ethernet Adapter - Packet Scheduler Miniport.',
                        IFDESCR          => 'QLogic 1Gb PCI Ethernet Adapter - Packet Scheduler Miniport.',
                        IFTYPE           => 'ethernetCsmacd(6)',
                        IFSPEED          => '1000000000',
                        IFMTU            => '1500',
                        MAC              => '00:60:16:1B:CD:7A',
                        IFSTATUS         => 'dormant(5)',
                        IFINTERNALSTATUS => 'up(1)',
                        IFLASTCHANGE     => '(3029065326) 350 days, 14:04:13.26',
                        IFINOCTETS       => '0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
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

    my %device0 = getDeviceInfo($snmp);
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp  => $snmp,
        model => $model,
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
