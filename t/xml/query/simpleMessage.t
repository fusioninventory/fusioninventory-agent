#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query;

plan tests => 8;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query->new();
} qr/^no deviceid/, 'no device id';

throws_ok {
    $message = FusionInventory::Agent::XML::Query->new(
        deviceid => 'foo',
    );
} qr/^no query/, 'no query type';

lives_ok {
    $message = FusionInventory::Agent::XML::Query->new(
        deviceid => 'foo',
        query    => 'TEST',
        foo      => 'foo',
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query');

my $tpp = XML::TreePP->new();

is_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            FOO      => 'foo',
            QUERY    => 'TEST'
        }
    },
    'expected content'
);

lives_ok {
    $message = FusionInventory::Agent::XML::Query->new(
        deviceid => 'foo',
        query    => 'TEST',
        foo => 'foo',
        castor => [
            {
                FOO => 'fu',
                FFF => 'GG',
                GF =>  [ { FFFF => 'GG' } ]
            },
            {
                FddF => [ { GG => 'O' } ]
            }
        ]
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query');

is_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            CASTOR => [
                {
                    FFF => 'GG',
                    FOO => 'fu',
                    GF => { FFFF => 'GG' }
                },
                {
                    FddF => { GG => 'O' }
                }
            ],
            DEVICEID => 'foo',
            FOO => 'foo',
            QUERY => 'TEST'
        }
    },
    'expected content'
);
