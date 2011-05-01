#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Config;
use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Logger;

plan tests => 10;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $inventory;
throws_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new();
} qr/^no deviceid/, 'no device id';

lives_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => 'foo',
        logger   => $logger
    );
} 'everything OK';

isa_ok($inventory, 'FusionInventory::Agent::XML::Query::Inventory');

my $tpp = XML::TreePP->new();
my $content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'INVENTORY',
        CONTENT => {
            HARDWARE => {
                ARCHNAME => $Config{archname},
                VMSYSTEM => 'Physical'
            },
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING
        },
    }
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'initial state'
);

$inventory->processChecksum();
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{CHECKSUM} = 262143;
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'initial state, after checksum computation'
);

$inventory->addEntry(
    section => 'CPUS',
    entry   => {
        NAME         => 'void CPU',
        SPEED        => 1456,
        MANUFACTURER => 'FusionInventory Developers',
        SERIAL       => 'AEZVRV',
        THREAD       => 3,
        CORE         => 1
    }
);
$content->{REQUEST}->{CONTENT}->{CPUS} = {
    CORE         => 1,
    MANUFACTURER => 'FusionInventory Developers',
    NAME         => 'void CPU',
    SERIAL       => 'AEZVRV',
    SPEED        => 1456,
    THREAD       => 3,
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'CPU added'
);

$inventory->setGlobalValues();
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{PROCESSORN} = 1;
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{PROCESSORS} = 1456;
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{PROCESSORT} = 'void CPU';
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'CPU added, after global values computation'
);

$inventory->processChecksum();
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{CHECKSUM} = 1;
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'CPU added, after checksum computation'
);

$inventory->addEntry(
    section => 'DRIVES',
    entry   => {
        FILESYSTEM => 'ext3',
        FREE       => 9120,
        SERIAL     => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
        TOTAL      => 18777,
        TYPE       => '/',
        VOLUMN     => '/dev/sda2',
    }
);
$content->{REQUEST}->{CONTENT}->{DRIVES} = {
    FILESYSTEM => 'ext3',
    FREE       => 9120,
    SERIAL     => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
    TOTAL      => 18777,
    TYPE       => '/',
    VOLUMN     => '/dev/sda2'
};
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'drive added'
);

$inventory->processChecksum();
$content->{REQUEST}->{CONTENT}->{HARDWARE}->{CHECKSUM} = 513;
is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    $content,
    'drive added, after checksum computation'
);
