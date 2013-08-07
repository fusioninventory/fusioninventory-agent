#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'alcatel/unknown.1.walk' => [
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CB-C005-127-os6400',
            MAC          => 'E8:E7:32:2B:C1:E2',
        },
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CB-C005-127-os6400',
            MAC          => 'E8:E7:32:2B:C1:E2',
            MODELSNMP    => 'Networking2189',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'M4682816',
        }
    ],
    'alcatel/unknown.2.walk' => [
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CP-153-127',
            MAC          => 'E8:E7:32:2B:C1:E2',
        },
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CP-153-127',
            MAC          => 'E8:E7:32:2B:C1:E2',
            MODELSNMP    => 'Networking2189',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'M4682816',
        }
    ]
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} elsif (!$ENV{SNMPMODEL_DATABASE}) {
    plan skip_all => 'SNMP models database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
);

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my %device0 = getDeviceInfo($snmp);
    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
