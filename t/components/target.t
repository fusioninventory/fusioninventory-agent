#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use URI;

use FusionInventory::Agent::Target::Server;

plan tests => 3;

my $target;
throws_ok {
    $target = FusionInventory::Agent::Target::Server->new();
} qr/^no url parameter/,
'instanciation: no url';

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'http://my.domain.tld',
    id         => 'target2'
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'missing path');

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'my.domain.tld',
    id         => 'target3'
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'bare hostname');
