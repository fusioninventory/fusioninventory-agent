#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::Exception;
use Test::More;
use XML::TreePP;

use FusionInventory::Agent::Message::Outbound;

plan tests => 7;

my $message;
throws_ok {
    $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => 'foo',
    );
} qr/^no query/, 'no query type';

lives_ok {
    $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => 'foo',
        query    => 'TEST',
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::Message::Outbound');

my $tpp = XML::TreePP->new();

cmp_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY    => 'TEST'
        }
    },
    'expected content'
);

lives_ok {
    $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => 'foo',
        query    => 'TEST',
        content  => [
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

isa_ok($message, 'FusionInventory::Agent::Message::Outbound');

cmp_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            CONTENT => [
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
            QUERY    => 'TEST'
        }
    },
    'expected content'
);
