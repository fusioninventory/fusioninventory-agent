#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query::Inventory;

plan tests => 5;

my $inventory;
throws_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new();
} qr/^no content/, 'no content';

throws_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new(
        content => {
            HARDWARE => {
                ARCHNAME => 'x86_64-linux-thread-multi',
                VMSYSTEM => 'Physical'
            },
        },
    );
} qr/^no deviceid/, 'no device id';

lives_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => 'foo',
        content => {
            HARDWARE => {
                ARCHNAME => 'x86_64-linux-thread-multi',
                VMSYSTEM => 'Physical'
            },
        },
    );
} 'everything OK';

isa_ok($inventory, 'FusionInventory::Agent::XML::Query::Inventory');

my $tpp = XML::TreePP->new();

is_deeply(
    scalar $tpp->parse($inventory->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY => 'INVENTORY',
            CONTENT => {
                HARDWARE => {
                    ARCHNAME => 'x86_64-linux-thread-multi',
                    VMSYSTEM => 'Physical'
                },
            },
        }
    },
    'expected content'
);
