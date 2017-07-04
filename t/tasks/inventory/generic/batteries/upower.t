#!/usr/bin/perl
use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower;

my %testUpowerEnumerate = (
    'enumerate_1.txt' => {
        extractedNames     => [
            '/org/freedesktop/UPower/devices/battery_BAT1'
        ]
    }
);

my %testUpowerInfos = (
    'infos_1.txt' => {
        extractedData => {
            NAME         => 'G71C000G7210',
            CAPACITY     => '39,264 Wh',
            VOLTAGE      => '14,8 V',
            CHEMISTRY    => 'lithium-ion',
            SERIAL       => 0,
            MANUFACTURER => undef
        }
    }
);

plan tests =>
    scalar (keys %testUpowerEnumerate) +
    scalar (keys %testUpowerInfos) +
    1;

foreach my $test (keys %testUpowerEnumerate) {
    my $file = 'resources/generic/batteries/upower/'.$test;
    my @battNames = FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower::_getBatteriesNameFromUpower(
        file => $file
    );
    my @sortedExpected = sort { $a cmp $b } @{$testUpowerEnumerate{$test}->{extractedNames}};
    my @sortedBattNames = sort { $a cmp $b } @battNames;
    cmp_deeply (
        \@sortedBattNames,
        \@sortedExpected,
        "$test: _getBatteriesNameFromUpower()"
    );
}

foreach my $test (keys %testUpowerInfos) {
    my $file = 'resources/generic/batteries/upower/' . $test;
    my $battData = FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower::_getBatteryDataFromUpower(
        file => $file
    );
    cmp_deeply(
        $battData,
        $testUpowerInfos{$test}->{extractedData},
        "$test: _getBatteriesDataFromUpower()"
    )
}
