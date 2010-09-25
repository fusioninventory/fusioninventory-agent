#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use XML::TreePP;
use FusionInventory::Agent::XML::Query::SimpleMessage;

plan tests => 8;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new();
} qr/^No msg/, 'no message';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        msg => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        target => { deviceid => 'test' },
        msg => {
            QUERY => 'TEST',
            FOO   => 'foo',
            BAR   => 'bar'
        },
    });
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::SimpleMessage');

my $tpp = XML::TreePP->new();
my $content;

$content = {
    REQUEST => {
        BAR      => 'bar',
        DEVICEID => 'test',
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
    $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        target => { deviceid => 'test' },
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
    });
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
        DEVICEID => 'test',
        FOO => 'foo',
        QUERY => 'TEST'
    }
};
is_deeply(
    scalar $tpp->parse($message->getContent()),
    $content,
    'expected content'
);
