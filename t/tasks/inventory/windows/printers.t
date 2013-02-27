#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Win32::Printers;

my %tests = (
    xppro1 => {
        USB001 => '49R8Ka',
        USB002 => undef,
        USB003 => undef
    },
    xppro2 => {
        USB001 => 'J5J126789',
        USB003 => 'JV40VNJ',
        USB004 => undef,
    },
    7 => {
        USB001 => 'MY26K1K34C2L'
    }
);

my $plan = 0;
foreach my $test (keys %tests) {
    $plan += scalar (keys %{$tests{$test}});
}
plan tests => $plan;

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Task::Inventory::Win32::Printers'
);

foreach my $test (keys %tests) {
    $module->mock(
        'getRegistryKey',
        mockGetRegistryKey($test)
    );

    foreach my $port (keys %{$tests{$test}}) {
        is(
            FusionInventory::Agent::Task::Inventory::Win32::Printers::_getUSBPrinterSerial($port),
            $tests{$test}->{$port},
            "$test sample, $port printer"
        );
    }
}
