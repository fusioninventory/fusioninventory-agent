#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::Input::Generic::Storages::HP;
use Test::More;

plan tests => 3;

my @slots = qw/
    2
/;

my @drives = qw/
    2I:1:1
    2I:1:2
/;

my $storage = {
    NAME         => 'WDC WD740ADFD-00',
    FIRMWARE     => '21.07QR4',
    SERIALNUMBER => 'WD-WMANS1732855',
    TYPE         => 'disk',
    DISKSIZE     => '74300',
    DESCRIPTION  => 'SATA',
    MODEL        => 'WDC WD740ADFD-00',
    MANUFACTURER => 'Western Digital'
};

is_deeply(
    [ FusionInventory::Agent::Task::Inventory::Input::Generic::Storages::HP::_getSlots(file => 'resources/generic/hpacucli/slots') ],
    [ @slots ],
    'slots extraction'
);

is_deeply(
    [ FusionInventory::Agent::Task::Inventory::Input::Generic::Storages::HP::_getDrives(file => 'resources/generic/hpacucli/drives') ],
    [ @drives ],
    'drives extraction'
);

is_deeply(
    FusionInventory::Agent::Task::Inventory::Input::Generic::Storages::HP::_getStorage(file => 'resources/generic/hpacucli/storage'),
    $storage,
    'storage extraction'
);
