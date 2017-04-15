#!/usr/bin/perl

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;
use URI;

use FusionInventory::Agent::Controller;

plan tests => 6;

my $target;

throws_ok {
    $target = FusionInventory::Agent::Controller->new();
} qr/^no url parameter/,
'instanciation: no base directory';


lives_ok {
    $target = FusionInventory::Agent::Controller->new(
        url        => 'http://my.domain.tld/ocsinventory',
    );
} 'instanciation: ok';

is($target->{id}, 'server0', "identifier");

$target = FusionInventory::Agent::Controller->new(
    url        => 'http://my.domain.tld',
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'missing path');

$target = FusionInventory::Agent::Controller->new(
    url        => 'my.domain.tld',
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'bare hostname');

is($target->getMaxDelay(), 3600, 'default value');
my $nextRunDate = $target->getNextRunDate();
