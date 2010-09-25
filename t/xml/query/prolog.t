#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use FusionInventory::Agent::XML::Query::Prolog;
use XML::TreePP;

plan tests => 5;

my $message;
throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
    });
} qr/^No token/, 'no token';

throws_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
        token => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $message = FusionInventory::Agent::XML::Query::Prolog->new({
        target => { deviceid => 'foo' },
        token => 'foo',
    });
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
