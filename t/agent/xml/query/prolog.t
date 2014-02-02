#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::Exception;
use Test::More;
use XML::TreePP;

use FusionInventory::Agent::XML::Query;

plan tests => 3;

my $message;

lives_ok {
    $message = FusionInventory::Agent::XML::Query->new(
        query    => 'PROLOG',
        token    => '12345678',
        deviceid => 'foo',
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query');

my $tpp = XML::TreePP->new();

cmp_deeply(
    scalar $tpp->parse($message->getContent()),
    {
        REQUEST => {
            DEVICEID => 'foo',
            TOKEN    => '12345678',
            QUERY    => 'PROLOG',
        }
    },
    'expected content'
);
