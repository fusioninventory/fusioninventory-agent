#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;
use FusionInventory::Agent::Task::WakeOnLan;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

my @payload_tests = (
    '0024D66F813A',
    'A4BADBA5F5FA'
);

my %win32deviceid_tests = (
    7 => {
        'PCI\VEN_10EC&DEV_8168&SUBSYS_84321043&REV_06\4&87D54EE&0&00E5'
            => '\Device\NPF_{442CDFAD-10E9-45B6-8CF9-C829034793B0}'
    }
);

plan tests =>
    (scalar @payload_tests * 2) +
    (scalar keys %win32deviceid_tests);

foreach my $test (@payload_tests) {
    my $payload = FusionInventory::Agent::Task::WakeOnLan->_getPayload($test);
    my ($header, $values) = unpack('H12H192', $payload);
    is($header, 'ffffffffffff', "payload header for $test");
    is($values, lc($test) x 16, "payload values for $test");
}

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Tools::Win32'
);

foreach my $sample (keys %win32deviceid_tests) {
    $module->mock(
        'getRegistryKey',
        mockGetRegistryKey($sample)
    );

    foreach my $pnpid (keys %{$win32deviceid_tests{$sample}}) {
        my $deviceid =
            FusionInventory::Agent::Task::WakeOnLan::_getWin32DeviceId($pnpid);
        is(
            $deviceid,
            $win32deviceid_tests{$sample}->{$pnpid},
            "$sample sample, $pnpid device"
        );
    }
}

