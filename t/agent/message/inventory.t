#!/usr/bin/perl

use strict;
use warnings;

use Config;
use Test::Deep;
use Test::Exception;
use Test::More;
use XML::TreePP;

use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Message::Outbound;

plan tests => 4;

my $query;
my $inventory =  FusionInventory::Agent::Inventory->new();

lives_ok {
    $query = FusionInventory::Agent::Message::Outbound->new(
        query    => 'INVENTORY',
        deviceid => 'foo',
        content  => $inventory->getContent()
    );
} 'everything OK';

isa_ok($query, 'FusionInventory::Agent::Message::Outbound');

my $tpp = XML::TreePP->new();

cmp_deeply(
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

$query = FusionInventory::Agent::Message::Outbound->new(
    query    => 'INVENTORY',
    deviceid => 'foo',
    content => $inventory->getContent()
);

cmp_deeply(
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
