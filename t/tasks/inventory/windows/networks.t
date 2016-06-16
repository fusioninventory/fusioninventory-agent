#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;
use UNIVERSAL::require;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use Config;
# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

Test::NoWarnings->use();

FusionInventory::Agent::Task::Inventory::Win32::Networks->require();

my %tests = (
    xp => {
        'PCI\VEN_1022&DEV_2000&SUBSYS_20001022&REV_10\\4&47B7341&0&0088' => 'ethernet',
        'ROOT\\MS_PSCHEDMP\\0001' => undef,
        'ROOT\\MS_PSCHEDMP\\0002' => undef,
        'ROOT\\MS_PSCHEDMP\\0003' => undef,
        'ROOT\\MS_PPTPMINIPORT\\0000' => undef,
        'ROOT\\MS_PPPOEMINIPORT\\0000' => undef
    },
);

my $plan = 1;
foreach my $test (keys %tests) {
    $plan += scalar (keys %{$tests{$test}});
}
plan tests => $plan;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Win32::Networks'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getRegistryKey',
        mockGetRegistryKey($test)
    );

    foreach my $deviceId (keys %{$tests{$test}}) {
        is(
            FusionInventory::Agent::Task::Inventory::Win32::Networks::_getMediaType($deviceId),
            $tests{$test}->{$deviceId},
            "$test sample, $deviceId device"
        );
    }
}
