#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::Printers;

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

foreach my $test (keys %tests) {
    my $printKey = load_registry("resources/win32/registry/$test-USBPRINT.reg");
    my $usbKey   = load_registry("resources/win32/registry/$test-USB.reg");
    foreach my $port (keys %{$tests{$test}}) {
        my $prefix = FusionInventory::Agent::Task::Inventory::Input::Win32::Printers::_getUSBPrefix($printKey, $port);
        my $serial = FusionInventory::Agent::Task::Inventory::Input::Win32::Printers::_getUSBSerial($usbKey, $prefix);

        is($serial, $tests{$test}->{$port}, "serial for printer $port");
    }
}
