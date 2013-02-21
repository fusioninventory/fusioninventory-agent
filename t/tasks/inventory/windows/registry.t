#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;

use FusionInventory::Test::Utils;

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use FusionInventory::Agent::Task::Inventory::Input::Win32::Registry;


if ($OSNAME ne 'MSWin32') {
    plan skip_all => 'Windows-specific test';
} else {
    plan tests => 8;
}

my @data;

@data = FusionInventory::Agent::Task::Inventory::Input::Win32::Registry::_getRegistryData(
    registry => {
        NAME => 'REGISTRY',
        PARAM => {
            NAME    => 'CurrentVersion',
            content => 'ProductId',
            REGTREE => '2',
            REGKEY  => 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion'
        }
    }
);
ok(@data == 1, "unique entry");
ok($data[0]->{entry}{REGVALUE}, "unique entry: REGVALUE");
ok($data[0]->{entry}{NAME} eq 'CurrentVersion', "unique entry: NAME");

@data = FusionInventory::Agent::Task::Inventory::Input::Win32::Registry::_getRegistryData(
    registry => {
        NAME => 'REGISTRY',
        PARAM => [
            {
                NAME    => 'ProductID',
                content => 'ProductId',
                REGTREE => '2',
                REGKEY  => 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion'
            },
            {
                 NAME    => 'CurrentVersion',
                 content => '*',
                 REGTREE => '2',
                 REGKEY  => 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion'
            }
        ]
    }
);

ok(@data > 4, "Wildcard test");
ok($data[0]->{entry}{REGVALUE}, "Wildcard test: REGVALUE");
ok($data[0]->{entry}{NAME} eq 'ProductID', "Wildcard test NAME (1/3)");
ok($data[1]->{entry}{NAME} eq 'CurrentVersion', "Wildcard test NAME (2/3)");
ok($data[2]->{entry}{NAME} eq 'CurrentVersion', "Wildcard test NAME (3/3)");
