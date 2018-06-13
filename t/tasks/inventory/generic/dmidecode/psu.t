#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu;

my %tests = (
    'dell-fx160' => undef,
    'hp-dl180' => [
        {
            PARTNUM        => '511777-001',
            SERIALNUMBER   => '5ANLE0BLLZ225W',
            MANUFACTURER   => 'HP',
            POWER_MAX      => '0.460 W',
            HOTREPLACEABLE => 'No',
            LOCATION       => 'Bottom PS Bay',
            NAME           => 'Power Supply 1',
            PLUGGED        => 'Yes',
            STATUS         => 'Present, <OUT OF SPEC>',
        }
    ],
    'lenovo-thinkpad' => [
        # Type 39 entry is a battery
    ],
    'windows-7' => [
        # 2 powersupplies, but no serial number, no partnum and no name
    ],
);

plan tests => 2 *(scalar keys %tests) + 1;

foreach my $test (keys %tests) {
    my $file = "resources/generic/dmidecode/$test";
    my $inventory = FusionInventory::Test::Inventory->new();

    lives_ok {
        FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu::doInventory(
            inventory   => $inventory,
            file        => $file
        );
    } "$test: runInventory()";

    my $psu = $inventory->getSection('POWERSUPPLIES') || [];
    cmp_deeply(
        $psu,
        $tests{$test} || [],
        "$test: parsing"
    );
}
