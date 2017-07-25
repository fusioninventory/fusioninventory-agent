#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery;
use FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower;

my %tests = (
    'freebsd-6.2' => undef,
    'freebsd-8.1' => [
        {
            NAME         => 'EV06047',
            SERIAL       => '61E6',
            MANUFACTURER => 'LGC-LGC',
            CHEMISTRY    => 'Lithium Ion',
            VOLTAGE      => 10800,
            CAPACITY     => 4400,
            DATE         => '15/01/2010'
        }
    ],
    'linux-2.6' => [
        {
            NAME         => 'DELL C129563',
            MANUFACTURER => 'Samsung',
            SERIAL       => '7734',
            CHEMISTRY    => 'LION',
            VOLTAGE      => 11100,
            CAPACITY     => 48000,
            DATE         => '11/03/2006'
        }
    ],
    'openbsd-3.7' => undef,
    'openbsd-3.8' => undef,
    'rhel-2.1' => undef,
    'rhel-3.4' => undef,
    'rhel-4.3' => undef,
    'rhel-4.6' => undef,
    'windows' => [
        {
            NAME         => 'L9088A',
            SERIAL       => '2000417915',
            DATE         => '19/09/2002',
            MANUFACTURER => 'Toshiba',
            CHEMISTRY    => 'Lithium Ion',
            VOLTAGE      => 10800,
            CAPACITY     => 0
        }
    ],
    'windows-hyperV' => undef
);

my %testUpowerMerged = (
    'infos_1.txt' => {
        files => {
            dmidecode => 'dmi_decode.txt',
            upowerInfos => {
                '/org/freedesktop/UPower/devices/battery_BAT1' => 'infos_1.txt',
            },
            upowerNames => 'enumerate_1.txt'
        },
        mergedData => [
            {
                NAME         => 'G71C000G7210',
                CAPACITY     => '39,264 Wh',
                VOLTAGE      => '14,8 V',
                CHEMISTRY    => 'lithium-ion',
                SERIAL       => 0,
                MANUFACTURER => 'Toshiba'
            }
        ]
    },
    'upower_info_2.txt' => {
        files => {
            dmidecode => 'dmidecode_2.txt',
            upowerInfos => {
                '/org/freedesktop/UPower/devices/battery_BAT0' => 'upower_info_2.txt',
            },
            upowerNames => 'upower_enumerate_2.txt'
        },
        mergedData => [
            {
                NAME         => 'DELL JHXPY53',
                CAPACITY     => '53,4052 Wh',
                VOLTAGE      => '8,541 V',
                CHEMISTRY    => 'lithium-polymer',
                SERIAL       => 3682,
                MANUFACTURER => 'SMP',
                DATE         => '10/11/2015'
            }
        ]
    }
);

plan tests =>
    (scalar keys %tests)               +
    (scalar grep { $_ } values %tests) +
    (scalar keys %testUpowerMerged) * 5 +
    1;

my $batterySectionName = 'BATTERIES';
my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $batteries = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBatteries(file => $file);
    cmp_deeply($batteries, $tests{$test}, "$test: parsing");
    next unless $batteries;
    lives_ok {
            $inventory->addEntry(section => $batterySectionName, entry => $batteries->[0]);
        } "$test: registering";
}

my $filesPath = 'resources/generic/batteries/upower/';
foreach my  $test (keys %testUpowerMerged) {
    $inventory = FusionInventory::Test::Inventory->new();

    my @batteriesName = FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower::_getBatteriesNameFromUpower(
        file => $filesPath . $testUpowerMerged{$test}->{files}->{upowerNames}
    );
    ok (@batteriesName && (scalar @batteriesName == 1));

    my @batteriesData = ();
    foreach my $battName (@batteriesName) {
        my $battData = FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower::_getBatteryDataFromUpower(
            file => $filesPath . $testUpowerMerged{$test}->{files}->{upowerInfos}->{$battName}
        );
        push @batteriesData, $battData
    }
    ok (@batteriesData && (scalar @batteriesData == 1));

    foreach my $batt (@batteriesData) {
        push @{$inventory->{content}->{BATTERIES}}, $batt;
    }
    my $section = $inventory->getSection($batterySectionName);
    ok (defined $section && scalar @$section == 1);

    my $batteriesFromDmiDecode = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBatteries(
        file => $filesPath . $testUpowerMerged{$test}->{files}->{dmidecode}
    );
    FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_mergeBatteries($inventory, $batteriesFromDmiDecode);

    $section = $inventory->getSection($batterySectionName);
    ok (
        defined $section && scalar @$section == 1,
            'defined $section : ' . ((not defined $section) ? 'not' : '' . ' defined ; ') . ((defined $section) ? scalar @$section : '')
    );
    my @section = sort { $a->{NAME} cmp $b->{NAME} && $a->{SERIAL} cmp $b->{SERIAL} } @$section;
    my @expected = sort { $a->{NAME} cmp $b->{NAME} && $a->{SERIAL} cmp $b->{SERIAL} } @{$testUpowerMerged{$test}->{mergedData}};
    cmp_deeply (
        \@section,
        \@expected,
        "$test _mergeBatteries()"
    );
}
