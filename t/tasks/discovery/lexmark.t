#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

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
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
    my %device0 = getDeviceInfo($sysdescr, $snmp);
    my %device1 = getDeviceInfo($sysdescr, $snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
