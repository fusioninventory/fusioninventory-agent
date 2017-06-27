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

my %tests = (
    'freebsd-6.2' => undef,
    'freebsd-8.1' => {
        NAME         => 'EV06047',
        SERIAL       => '61E6',
        MANUFACTURER => 'LGC-LGC',
        CHEMISTRY    => 'Lithium Ion',
        VOLTAGE      => 10800,
        CAPACITY     => 4400,
        DATE         => '15/01/2010'
    },
    'linux-2.6' => {
        NAME         => 'DELL C129563',
        MANUFACTURER => 'Samsung SDI',
        SERIAL       => '7734',
        CHEMISTRY    => 'LION',
        VOLTAGE      => 11100,
        CAPACITY     => 48000,
        DATE         => '11/03/2006'
    },
    'openbsd-3.7' => undef,
    'openbsd-3.8' => undef,
    'rhel-2.1' => undef,
    'rhel-3.4' => undef,
    'rhel-4.3' => undef,
    'rhel-4.6' => undef,
    'windows' => {
        NAME         => 'L9088A',
        SERIAL       => '2000417915',
        DATE         => '19/09/2002',
        MANUFACTURER => 'TOSHIBA',
        CHEMISTRY    => 'Lithium Ion',
        VOLTAGE      => 10800,
        CAPACITY     => 0
    },
    'windows-hyperV' => undef
);

my %testUpowerEnumerate = (
    'enumerate_1.txt' => {
        extractedName     => '/org/freedesktop/UPower/devices/battery_BAT1',
    }
);

my %testUpowerInfos = (
    'infos_1.txt' => {
        extractedData => {
            NAME      => 'G71C000G7210',
            CAPACITY  => '39,264 Wh',
            VOLTAGE   => '14,8 V',
            CHEMISTRY => 'lithium-ion'
        }
    }
);

my %testUpowerMerged = (
    'infos_1.txt' => {
        files => {
            dmidecode => 'dmi_decode.txt',
            upowerInfos => 'infos_1.txt'
        },
        mergedData => {
            MANUFACTURER => 'TOSHIBA',
            NAME      => 'TOSHIBA G71C000G7210',
            CAPACITY  => '39,264 Wh',
            VOLTAGE   => '14,8 V',
            CHEMISTRY => 'Li-ION',
            SERIAL    => '0000000000',
            DATE      => undef
        }
    }
);

plan tests =>
    (scalar keys %tests)               +
    (scalar grep { $_ } values %tests) +
    scalar (keys %testUpowerEnumerate) +
    scalar (keys %testUpowerInfos) +
    scalar (keys %testUpowerMerged) +
    1;

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $battery = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBattery(file => $file);
    cmp_deeply($battery, $tests{$test}, "$test: parsing");
    next unless $battery;
    lives_ok {
        $inventory->addEntry(section => 'BATTERIES', entry => $battery);
    } "$test: registering";
}

foreach my $test (keys %testUpowerEnumerate) {
    my $file = 'resources/generic/upower/'.$test;
    my $battName = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBatteryNameFromUpower(
        file => $file
    );
    ok ($battName eq $testUpowerEnumerate{$test}->{extractedName}, "$test: _getBatteryNameFromUpower()");
}

foreach my $test (keys %testUpowerInfos) {
    my $file = 'resources/generic/upower/' . $test;
    my $battData = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBatteryDataFromUpower(
        file => $file
    );
    cmp_deeply(
        $battData,
        $testUpowerInfos{$test}->{extractedData},
        "$test: _getBatteryDataFromUpower()"
    );
}

foreach my $test (keys %testUpowerMerged) {
    my $battery = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBattery(
        file => 'resources/generic/upower/' . $testUpowerMerged{$test}->{files}->{dmidecode}
    );
    my $batteryAdditionalData = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_getBatteryDataFromUpower(
        file => 'resources/generic/upower/' . $testUpowerMerged{$test}->{files}->{upowerInfos}
    );
    $battery = FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery::_mergeData($battery, $batteryAdditionalData);
    cmp_deeply(
        $battery,
        $testUpowerMerged{$test}->{mergedData},
        "$test: _mergeData()"
    );
}

