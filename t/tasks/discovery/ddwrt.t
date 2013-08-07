#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'ddwrt/unknown.1.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'nasbcs',
            SNMPHOSTNAME => 'nasbcs',
            MAC          => '00:14:FD:14:35:2C',
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'nasbcs',
            SNMPHOSTNAME => 'nasbcs',
            MAC          => '00:14:FD:14:35:2C',
        }
    ],
    'ddwrt/unknown.2.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'Linux nasbcs 2.6.33N7700 #5 SMP Wed Jan 26 12:14:33 CST 2011 i686',
            SNMPHOSTNAME => undef,
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'Linux nasbcs 2.6.33N7700 #5 SMP Wed Jan 26 12:14:33 CST 2011 i686',
            SNMPHOSTNAME => undef,
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.3.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'aleph.bu.dauphine.fr',
            SNMPHOSTNAME => 'aleph.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'aleph.bu.dauphine.fr',
            SNMPHOSTNAME => 'aleph.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.4.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primotest.bu.dauphine.fr',
            SNMPHOSTNAME => 'primotest.bu.dauphine.fr',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primotest.bu.dauphine.fr',
            SNMPHOSTNAME => 'primotest.bu.dauphine.fr',
            MAC          => undef
        }
    ],
    'ddwrt/unknown.5.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primo.bu.dauphine.fr',
            SNMPHOSTNAME => 'primo.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primo.bu.dauphine.fr',
            SNMPHOSTNAME => 'primo.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.6.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'metalib.bu.dauphine.fr',
            SNMPHOSTNAME => 'metalib.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'metalib.bu.dauphine.fr',
            SNMPHOSTNAME => 'metalib.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => 'resources/dictionary.xml'
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
