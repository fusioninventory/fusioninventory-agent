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

plan tests =>
    (scalar keys %tests)               +
    (scalar grep { $_ } values %tests) +
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
