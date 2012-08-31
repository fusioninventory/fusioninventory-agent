#!/usr/bin/perl

use strict;
use warnings;

use Config;
use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Task::Inventory::Inventory;

plan tests => 5;

my $query;
throws_ok {
    $query = FusionInventory::Agent::XML::Query::Inventory->new();
} qr/^no content/, 'no content';

my $inventory =  FusionInventory::Agent::Task::Inventory::Inventory->new();
lives_ok {
    $query = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => 'foo',
        content  => $inventory->getContent()
    );
} 'everything OK';

isa_ok($query, 'FusionInventory::Agent::XML::Query::Inventory');

my $tpp = XML::TreePP->new();

is_deeply(
    scalar $tpp->parse($query->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY    => 'INVENTORY',
            CONTENT  => {
                HARDWARE => {
                    ARCHNAME => $Config{archname},
                    VMSYSTEM => 'Physical'
                },
                VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING,
            },
        }
    },
    'empty inventory, expected content'
);

$inventory->addEntry(
    section => 'SOFTWARES',
    entry   => {
        NAME => '<&>',
    }
);

$query = FusionInventory::Agent::XML::Query::Inventory->new(
    deviceid => 'foo',
    content => $inventory->getContent()
);

is_deeply(
    scalar $tpp->parse($query->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY => 'INVENTORY',
            CONTENT => {
                HARDWARE => {
                    ARCHNAME => $Config{archname},
                    VMSYSTEM => 'Physical'
                },
                VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING,
                SOFTWARES => {
                    NAME => '<&>'
                }
            },
        }
    },
    'additional content with prohibited characters, expected content'
);
