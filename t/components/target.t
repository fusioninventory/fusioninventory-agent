#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
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
    $target = FusionInventory::Agent::Target::Server->new(
        url => 'http://foo/bar'
    );
} qr/^no basevardir parameter/,
'instanciation: no base directory';

my $basevardir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);

throws_ok {
    $target = FusionInventory::Agent::Target::Server->new(
        url        => 'http://my.domain.tld/ocsinventory',
        basevardir => $basevardir
    );
} qr/^no id parameter/,
'instanciation: no id';

lives_ok {
    $target = FusionInventory::Agent::Target::Server->new(
        url        => 'http://my.domain.tld/ocsinventory',
        basevardir => $basevardir,
        id         => 'target1'
    );
} 'instanciation: ok';

my $storage_dir = "$basevardir/target1" ;
ok(-d $storage_dir, "storage directory creation");

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'http://my.domain.tld',
    basevardir => $basevardir,
    id         => 'target2'
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'missing path');

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'my.domain.tld',
    basevardir => $basevardir,
    id         => 'target3'
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'bare hostname');
