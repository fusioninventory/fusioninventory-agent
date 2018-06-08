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
use FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru;

my %tests = (
    '1' => {
        dmidecode   => [],
        fru         => [
            {
                PARTNUM        => '05NF18A01',
                SERIALNUMBER   => 'CN1797238QA8B4',
                MANUFACTURER   => 'DELL',
                NAME           => 'PWR SPLY,750WP,RDNT,DELTA',
            },
            {
                PARTNUM        => '05NF18A01',
                SERIALNUMBER   => 'CN1797238QA8EI',
                MANUFACTURER   => 'DELL',
                NAME           => 'PWR SPLY,750WP,RDNT,DELTA',
            },
        ]
    },
    '2' => {
        dmidecode   => [
            {
                PARTNUM        => 'To Be Filled By O.E.M.',
                SERIALNUMBER   => 'To Be Filled By O.E.M.',
                MANUFACTURER   => 'To Be Filled By O.E.M.',
                HOTREPLACEABLE => 'No',
                LOCATION       => 'To Be Filled By O.E.M.',
                NAME           => 'To Be Filled By O.E.M.',
                PLUGGED        => 'Yes',
                STATUS         => 'Present, OK',
            },
        ],
        fru         => [
            {
                PARTNUM        => 'To Be Filled By O.E.M.',
                SERIALNUMBER   => 'To Be Filled By O.E.M.',
                MANUFACTURER   => 'To Be Filled By O.E.M.',
                HOTREPLACEABLE => 'No',
                LOCATION       => 'To Be Filled By O.E.M.',
                NAME           => 'To Be Filled By O.E.M.',
                PLUGGED        => 'Yes',
                STATUS         => 'Present, OK',
            },
        ],
    },
    '3' => {
        dmidecode   => [],
        fru         => [],
    },
);

plan tests => 4 *(scalar keys %tests) + 1;

foreach my $index (keys %tests) {
    my $dmidecode = "resources/generic/powersupplies/dmidecode_$index.txt";
    my $inventory = FusionInventory::Test::Inventory->new();

    lives_ok {
        FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu::doInventory(
            inventory   => $inventory,
            file        => $dmidecode
        );
    } "test $index: dmidecode runInventory()";

    my $psu = $inventory->getSection('POWERSUPPLIES') || [];
    my @psu = sort { $a->{SERIALNUMBER} cmp $b->{SERIALNUMBER} } @{$psu};
    cmp_deeply(
        \@psu,
        $tests{$index}->{dmidecode},
        "test $index: parsing dmidecode"
    );

    my $fru = "resources/generic/powersupplies/fru_$index.txt";
    lives_ok {
        FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru::doInventory(
            inventory   => $inventory,
            file        => $fru
        );
    } "test $index: runInventory(s)";

    $psu = $inventory->getSection('POWERSUPPLIES') || [];
    @psu = sort { $a->{SERIALNUMBER} cmp $b->{SERIALNUMBER} } @{$psu};
    cmp_deeply(
        \@psu,
        $tests{$index}->{fru},
        "test $index: parsing fru"
    );
}
