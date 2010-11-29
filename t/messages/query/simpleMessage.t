#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Logger;

plan tests => 8;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new();
} qr/^no msg/, 'no message';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        msg => {
            QUERY => 'TEST',
            FOO   => 'foo',
            BAR   => 'bar'
        },
    );
} qr/^no deviceid/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        deviceid => 'foo',
        logger   => FusionInventory::Logger->new(),
        msg => {
            QUERY => 'TEST',
            FOO   => 'foo',
            BAR   => 'bar'
        },
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

my $tpp = XML::TreePP->new();
my $content;

$content = {
    REQUEST => {
        BAR      => 'bar',
        DEVICEID => 'foo',
        FOO      => 'foo',
        QUERY    => 'TEST'
    }
};
is_deeply(
    scalar $tpp->parse($message->getContent()),
    $content,
    'expected content'
);

lives_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        deviceid => 'foo',
        msg => {
            QUERY => 'TEST',
            FOO => 'foo',
            BAR => 'bar',
            CASTOR => [
                {
                    FOO => 'fu',
                    FFF => 'GG',
                    GF =>  [ { FFFF => 'GG' } ]
                },
                {
                    FddF => [ { GG => 'O' } ]
                }
            ]
        }
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

$content = {
    REQUEST => {
        BAR => 'bar',
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
};
is_deeply(
    scalar $tpp->parse($message->getContent()),
    $content,
    'expected content'
);
