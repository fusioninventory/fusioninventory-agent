#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query::Prolog;

plan tests => 5;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new();
} qr/^no token/, 'no token';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new(
        token => 'foo'
    );
} qr/^no deviceid/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new(
        token    => 'foo',
        deviceid => 'foo',
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::Prolog');

my $tpp = XML::TreePP->new();

is_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY    => 'PROLOG',
            TOKEN    => 'foo',
        }
    },
    'expected content'
);
