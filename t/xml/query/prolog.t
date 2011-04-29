#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use XML::TreePP;

use FusionInventory::Agent::XML::Query::Prolog;
use FusionInventory::Logger;

plan tests => 5;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new();
} qr/^no token/, 'no token';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new(
        token    => 'foo'
    );
} qr/^no deviceid/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new(
        deviceid => 'foo',
        token    => 'foo',
        logger   => FusionInventory::Logger->new(),
    );
} 'everything OK';

isa_ok($message, 'FusionInventory::Agent::XML::Query::Prolog');

my $tpp = XML::TreePP->new();
my $content = {
    REQUEST => {
        DEVICEID => 'foo',
        QUERY => 'PROLOG',
        TOKEN => 'foo',
    }
};
is_deeply(
    scalar $tpp->parse($message->getContent()),
    $content,
    'expected content'
);
