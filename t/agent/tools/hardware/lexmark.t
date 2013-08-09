#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep;
use YAML qw(LoadFile);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Test::Utils;

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
            MODEL        => undef,
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
            },
            CARTRIDGES => {
                TONERBLACK => 100
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                RECTOVERSO => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => '24',
                        MAC      => '00:00:00:00:00:00',
                        IFNUMBER => '1',
                        IFNAME   => 'lo0'
                    },
                    {
                        IFTYPE   => '6',
                        IFNUMBER => '2',
                        MAC      => '00:04:00:9C:6C:25',
                        IFNAME   => 'eth0'
                    },
                    {
                        IP => '127.0.0.1'
                    },
                    {
                        IP => '172.31.201.21'
                    }
                ]
            }
        }
    ],
    'lexmark/X792.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Lexmark',
                TYPE         => 'PRINTER',
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COLOR      => undef,
                FAXTOTAL   => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                BLACK      => undef,
                PRINTTOTAL => undef
            }
        }
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} elsif (!$ENV{SNMPMODEL_DATABASE}) {
    plan skip_all => 'SNMP models database required';
} else {
    plan tests => 3 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
);

my $index = LoadFile("$ENV{SNMPMODEL_DATABASE}/index.yaml");

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my %device0 = getDeviceInfo($snmp);
    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);

    my $model_id = $tests{$test}->[1]->{MODELSNMP};
    my $model = $model_id ?
        loadModel("$ENV{SNMPMODEL_DATABASE}/$index->{$model_id}") : undef;

    my $device3 = FusionInventory::Agent::Tools::Hardware::getDeviceFullInfo(
        device => {
            FILE => "$ENV{SNMPWALK_DATABASE}/$test",
            TYPE => 'PRINTER',
        },
        model => $model
    );
    cmp_deeply($device3, $tests{$test}->[2], $test);
}
