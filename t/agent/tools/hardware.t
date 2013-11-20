#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my @mac_tests = (
    [ 'd2:05:a8:6c:26:d5' , 'D2:05:A8:6C:26:D5' ],
    [ '0xD205A86C26D5'    , 'D2:05:A8:6C:26:D5' ],
    [ '0x6001D205A86C26D5', 'D2:05:A8:6C:26:D5' ],
);

plan tests =>
    scalar @mac_tests +
    2;

foreach my $test (@mac_tests) {
    is(
        getCanonicalMacAddress($test->[0]),
        $test->[1],
        "$test->[0] normalisation"
    );
}

my $snmp1 = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
    }
);

my %device1 = getDeviceBaseInfo($snmp1);
cmp_deeply(
    \%device1,
    { DESCRIPTION => 'foo' },
    'getDeviceBaseInfo() with no sysobjectid'
);

my $snmp2 = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
        '.1.3.6.1.2.1.1.2.0'        => [ 'STRING', '.1.3.6.1.4.1.45' ],
    }
);

my %device2 = getDeviceBaseInfo($snmp2);
cmp_deeply(
    \%device2,
    { DESCRIPTION => 'foo', TYPE => 'NETWORKING', MANUFACTURER => 'Nortel' },
    'getDeviceBaseInfo() with sysobjectid'
);
