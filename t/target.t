#!/usr/bin/perl

use strict;
use warnings;

use File::Temp qw/tempdir/;
use Test::More;
use Test::Exception;
use URI;

use FusionInventory::Agent::Target::Server;

plan tests => 7;

my $target;
throws_ok {
    $target = FusionInventory::Agent::Target::Server->new();
} qr/^no url parameter/,
'instanciation: no url';

throws_ok {
    $target = FusionInventory::Agent::Target::Server->new({
        url => 'http://foo/bar'
    });
} qr/^no basevardir parameter/,
'instanciation: no base directory';

my $basevardir = tempdir(CLEANUP => 1);

lives_ok {
    $target = FusionInventory::Agent::Target::Server->new({
        url        => 'http://my.domain.tld/ocsinventory',
        basevardir => $basevardir
    });
} 'instanciation: ok';

ok(-d "$basevardir/http:__my.domain.tld_ocsinventory", "storage directory creation");
is($target->{id}, 'server0', "identifier");

$target = FusionInventory::Agent::Target::Server->new({
    url        => 'http://my.domain.tld',
    basevardir => $basevardir
});
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'missing path');

$target = FusionInventory::Agent::Target::Server->new({
    url        => 'my.domain.tld',
    basevardir => $basevardir
});
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'bare hostname');
