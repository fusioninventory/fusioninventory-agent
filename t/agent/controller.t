#!/usr/bin/perl

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Controller;

plan tests => 10;

my $target;

throws_ok {
    $target = FusionInventory::Agent::Controller->new();
} qr/^no url parameter/,
'instanciation: no url parameter';

throws_ok {
    $target = FusionInventory::Agent::Controller->new(
    url => 'foo://bar',
);
} qr/^invalid protocol for URL parameter/,
'instanciation: invalid protocol for url parameter';

lives_ok {
    $target = FusionInventory::Agent::Controller->new(
        url => 'http://my.domain.tld/ocsinventory',
    );
} 'instanciation: ok';

is($target->getId(), 'my.domain.tld', 'identifier with full url');
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'final url with full url');

$target = FusionInventory::Agent::Controller->new(
    url => 'http://my.domain.tld',
);
is($target->getId(), 'my.domain.tld', 'identifier with partial url');
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'final url with partial url');

$target = FusionInventory::Agent::Controller->new(
    url => 'my.domain.tld',
);
is($target->getId(), 'my.domain.tld', 'identifier wih bare hostname');
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'final url with bare hostname');

is($target->getMaxDelay(), 3600, 'default value');
my $nextRunDate = $target->getNextRunDate();
