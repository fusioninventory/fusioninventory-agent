#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Generic::Storages::3ware;

plan tests => 4;

my @cards = (
    {
        id => 'c0',
        model => '9650SE-2LP'
    }
);

my @units = (
    {
        id => 'u0',
        index => 0
    }
);

my @ports = (
    {
        id => 'p0',
    },
    {
        id => 'p1',
    },
);

my @storages = (
    {
        FIRMWARE     => '21.07QR4',
        DISKSIZE     => 70912,
        DESCRIPTION  => 'SATA',
        MANUFACTURER => 'Western Digital',
        SERIALNUMBER => 'WD-WMANS1648590',
        MODEL        => 'WDC WD740ADFD-00NLR4',
        TYPE         => 'disk'
    }
);

cmp_deeply(
    [ FusionInventory::Agent::Task::Inventory::Generic::Storages::3ware::_getCards('resources/generic/tw_cli/cards') ],
    [ @cards ],
    'cards extraction'
);

cmp_deeply(
    [ FusionInventory::Agent::Task::Inventory::Generic::Storages::3ware::_getUnits({ id => 'c0' }, 'resources/generic/tw_cli/units') ],
    [ @units ],
    'units extraction'
);

cmp_deeply(
    [ FusionInventory::Agent::Task::Inventory::Generic::Storages::3ware::_getPorts({ id => 'c0' }, { id => 'u0' }, 'resources/generic/tw_cli/ports') ],
    [ @ports ],
    'ports extraction'
);

cmp_deeply(
    [ FusionInventory::Agent::Task::Inventory::Generic::Storages::3ware::_getStorage({ id => 'c0', model => '9650SE-2LP' }, { id => 'p0' }, 'resources/generic/tw_cli/storage') ],
    [ @storages ],
    'storages extraction'
);
