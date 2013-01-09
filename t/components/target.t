#!/usr/bin/perl

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::Target::Server;

# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
} else {
    threads->use();
    plan tests => 11;
}

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

lives_ok {
    $target = FusionInventory::Agent::Target::Server->new(
        url        => 'http://my.domain.tld/ocsinventory',
        basevardir => $basevardir
    );
} 'instanciation: ok';

my $storage_dir = $OSNAME eq 'MSWin32' ?
    "$basevardir/http..__my.domain.tld_ocsinventory" :
    "$basevardir/http:__my.domain.tld_ocsinventory" ;
ok(-d $storage_dir, "storage directory creation");
is($target->{id}, 'server0', "identifier");

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'http://my.domain.tld',
    basevardir => $basevardir
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'missing path');

$target = FusionInventory::Agent::Target::Server->new(
    url        => 'my.domain.tld',
    basevardir => $basevardir
);
is($target->getUrl(), 'http://my.domain.tld/ocsinventory', 'bare hostname');

is($target->getMaxDelay(), 3600, 'default value');
my $nextRunDate = $target->getNextRunDate();

ok(-f "$storage_dir/target.dump", "state file existence");
$target = FusionInventory::Agent::Target::Server->new(
    url        => 'http://my.domain.tld/ocsinventory',
    basevardir => $basevardir
);
is($target->getNextRunDate(), $nextRunDate, 'state persistence');

# set target shared
$target->setShared();
# increment next run date in another thread
my $thread = threads->create(\&thread);
$thread->join();
is($target->getNextRunDate(), $nextRunDate + 1, 'nextRunDate is shared among threads');

sub thread {
    $target->setNextRunDate($nextRunDate + 1);
}
