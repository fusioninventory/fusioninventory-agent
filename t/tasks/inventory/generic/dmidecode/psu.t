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
        },
        {
            MANUFACTURER   => 'HP',
            HOTREPLACEABLE => 'No',
            PLUGGED        => 'Yes',
        },
    ],
    'lenovo-thinkpad' => [
        # Type 39 entry is a battery
    ],
    'windows-7' => [
        {
            PARTNUM        => 'To Be Filled By O.E.M.',
            SERIALNUMBER   => 'To Be Filled By O.E.M.',
            MANUFACTURER   => 'To Be Filled By O.E.M.',
            HOTREPLACEABLE => 'No',
            LOCATION       => 'To Be Filled By O.E.M.',
            NAME           => 'To Be Filled By O.E.M.',
            PLUGGED        => 'Yes',
        },
        {
            PARTNUM        => 'To Be Filled By O.E.M.',
            SERIALNUMBER   => 'To Be Filled By O.E.M.',
            MANUFACTURER   => 'To Be Filled By O.E.M.',
            HOTREPLACEABLE => 'No',
            LOCATION       => 'To Be Filled By O.E.M.',
            NAME           => 'To Be Filled By O.E.M.',
            PLUGGED        => 'Yes',
        }
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
