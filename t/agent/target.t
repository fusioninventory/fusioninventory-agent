#!/usr/bin/perl

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;
use URI;

use FusionInventory::Agent::Target::Server;

plan tests => 52;

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

# Test internal event APIs
ok( ! defined($target->getNextExpiredInternalEvent()), 'no internal event by default');
lives_ok {
    $target->registerInternalEvent( 300, "Task1", "eventname" );
} 'internal event registration';
# Not registered event while using bad arguments
ok(!defined($target->registerInternalEvent(undef, "Task1", "eventname")), 'no event registration 1');
ok(!defined($target->registerInternalEvent(30, undef, "eventname")), 'no event registration 2');
ok(!defined($target->registerInternalEvent(30, "", "eventname")), 'no event registration 3');
ok(!defined($target->registerInternalEvent(30, 0, "eventname")), 'no event registration 4');
ok(!defined($target->registerInternalEvent(30, "Task1", undef)), 'no event registration 5');
ok(!defined($target->registerInternalEvent(30, "Task1", "")), 'no event registration 6');
ok(!defined($target->registerInternalEvent(30, "Task1", 0)), 'no event registration 7');
# Check registered event
is(scalar @{$target->{nextInternalEvents}}, 1, 'only one event registered');
ok($target->{nextInternalEvents}->[0][0] > scalar(time), 'next event in the futur');
is($target->{nextInternalEvents}->[0][1], "Task1", 'next event category (related task)');
is($target->{nextInternalEvents}->[0][2], "eventname", 'next event name');
# Add some events and check the list
$target->registerInternalEvent( 3600, "Task1", "eventname-2" );
is(scalar @{$target->{nextInternalEvents}}, 2, '2 events registered');
ok($target->{nextInternalEvents}->[1][0] > scalar(time), 'later event in the futur');
is($target->{nextInternalEvents}->[1][1], "Task1", 'later event category (related task)');
is($target->{nextInternalEvents}->[1][2], "eventname-2", 'later event name');
$target->registerInternalEvent( 1800, "Task2", "eventname" );
is(scalar @{$target->{nextInternalEvents}}, 3, '3 events registered');
ok($target->{nextInternalEvents}->[1][0] > scalar(time), 'other later event in the futur, but in place 2');
is($target->{nextInternalEvents}->[1][1], "Task2", 'other later event category (related task), but in place 2');
is($target->{nextInternalEvents}->[1][2], "eventname", 'other later event name, but in place 2');
# Register event with other delay should move it in the list
$target->registerInternalEvent( 900, "Task1", "eventname-2" );
is(scalar @{$target->{nextInternalEvents}}, 3, 'Still 3 events registered');
ok($target->{nextInternalEvents}->[1][0] > scalar(time), 'later event still in the futur, and in place 2');
is($target->{nextInternalEvents}->[1][1], "Task1", 'later event category (related task), and in place 2');
is($target->{nextInternalEvents}->[1][2], "eventname-2", 'later event name, and in place 2');
$target->registerInternalEvent( -60, "Task1", "eventname-2" );
is(scalar @{$target->{nextInternalEvents}}, 3, 'Still 3 events registered');
ok($target->{nextInternalEvents}->[0][0] < scalar(time), 'event is in the past, and in first place');
is($target->{nextInternalEvents}->[0][1], "Task1", 'event category (related task) in first place');
is($target->{nextInternalEvents}->[0][2],"eventname-2", 'event name in first place');
# getting next expired event should return one event only
my ($task, $event);
lives_ok {
    ($task, $event) = $target->getNextExpiredInternalEvent();
} 'getting next internal event';
is($task, "Task1", 'next event category (related task)');
is($event, "eventname-2", 'next event name');
is(scalar @{$target->{nextInternalEvents}}, 2, 'still 2 events registered');
ok( ! defined($target->getNextExpiredInternalEvent()), 'no more expired internal event');
# Unregistering an event should reorganize the list
lives_ok {
    $target->registerInternalEvent( 0, "Task1", "eventname" );
} 'unregistring internal event';
is(scalar @{$target->{nextInternalEvents}}, 1, 'still one event registered');
ok($target->{nextInternalEvents}->[0][0] > scalar(time), 'leaving event in the futur, and in first place');
is($target->{nextInternalEvents}->[0][1], "Task2", 'leaving event category (related task), and in first place');
is($target->{nextInternalEvents}->[0][2], "eventname", 'leaving event name, and in first place');
ok( ! defined($target->getNextExpiredInternalEvent()), 'still no more expired internal event');
lives_ok {
    $target->registerInternalEvent( 0, "Task1", "eventname" );
} 'unregistring not registered internal event';
is(scalar @{$target->{nextInternalEvents}}, 1, 'still one event registered');
