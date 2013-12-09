#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep qw(cmp_deeply);
use XML::TreePP;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::Tools::Hardware;

my %tests = (
    'ricoh/Aficio_AP3800C.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => '00:00:74:71:17:ca',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => '00:00:74:71:17:ca',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio AP3800C',
                COMMENTS     => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio AP3800C',
                MEMORY       => '192',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.20.3.63',
                    ],
                },
                UPTIME       => '(166369300) 19 days, 6:08:13.00',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio AP3800C',
                COMMENTS     => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio AP3800C',
                MEMORY       => '192',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.20.3.63',
                    ],
                },
                UPTIME       => '(166369300) 19 days, 6:08:13.00',
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
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:f8:ba:6f',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:f8:ba:6f',
            MODELSNMP    => 'Printer0522',
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio MP C2050',
                COMMENTS     => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio MP C2050',
                MEMORY       => '768',
                LOCATION     => 'Schoelcher - 1er',
                IPS          => {
                    IP => [
                        '0.0.0.0',
                        '10.75.14.27',
                        '127.0.0.1',
                    ],
                },
                UPTIME       => '(234064600) 27 days, 2:10:46.00',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => undef,
                COMMENTS     => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
                NAME         => 'Aficio MP C2050',
                MEMORY       => '768',
                LOCATION     => 'Schoelcher - 1er',
                IPS          => {
                    IP => [
                        '0.0.0.0',
                        '10.75.14.27',
                        '127.0.0.1',
                    ],
                },
                UPTIME       => '(234064600) 27 days, 2:10:46.00',
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
                TONERCYAN        => '100',
                TONERMAGENTA     => '100',
                TONERYELLOW      => '100',
                WASTETONER       => '100',
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
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
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
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => '00:00:74:f3:01:95',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
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
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Ricoh',
                TYPE         => 'PRINTER',
                MODEL        => 'RICOH Aficio SP C420DN',
                COMMENTS     => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
                NAME         => 'Aficio SP C420DN',
                LOCATION     => 'Ugo',
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
plan tests => 4 * scalar keys %tests;

my ($dictionary, $index);
if ($ENV{SNMPMODELS_DICTIONARY}) {
    $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
        file => $ENV{SNMPMODELS_DICTIONARY}
    );
}
if ($ENV{SNMPMODELS_INDEX}) {
    $index = XML::TreePP->new()->parsefile($ENV{SNMPMODELS_INDEX});
}

foreach my $test (sort keys %tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );

    # first test: discovery without dictionary
    my %device1 = getDeviceInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        \%device1,
        $tests{$test}->[0],
        "$test: discovery, without dictionary"
    );

    # second test: discovery, with dictipnary
    SKIP: {
        skip "SNMP dictionary required, skipping", 1 unless $dictionary;

        my %device2 = getDeviceInfo(
            snmp       => $snmp,
            datadir    => './share',
            dictionary => $dictionary,
        );
        cmp_deeply(
            \%device2,
            $tests{$test}->[1],
            "$test: discovery, with dictionary"
        );
    };

    # third test: inventory without model
    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        datadir => './share'
    );
    cmp_deeply(
        $device3,
        $tests{$test}->[2],
        "$test: inventory, without model"
    );

    # fourth test: inventory, with model
    SKIP: {
        my $model_id = $tests{$test}->[1]->{MODELSNMP};
        skip "SNMP models index required, skipping", 1 unless $index;
        skip "No model associated, skipping", 1 unless $model_id;
        my $model = loadModel($index->{$model_id});

        my $device4 = getDeviceFullInfo(
            snmp    => $snmp,
            datadir => './share',
            model   => $model
        );
        cmp_deeply(
            $device4,
            $tests{$test}->[3],
            "$test: inventory, with model"
        );
    };
}
