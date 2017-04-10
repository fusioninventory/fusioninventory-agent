#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::Deep;
use Test::More;
use XML::TreePP;
use UNIVERSAL::require;
use Config;

use FusionInventory::Test::Utils;

# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

plan tests => 15;

FusionInventory::Agent::Task::NetInventory->use();

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netinventory', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netinventory', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$FusionInventory::Agent::Task::NetInventory::VERSION/,
    '--version stdout'
);

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    ''
);
ok($rc == 2, 'no target exit status');
like(
    $err,
    qr/no host nor file given, aborting/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    '--host 127.0.0.1 --file resources/walks/sample4.walk'
);
ok($rc == 0, 'success exit status');

my $content = XML::TreePP->new()->parse($out);
ok($content, 'valid output');

my $result = XML::TreePP->new()->parsefile('resources/walks/sample4.result');
$result->{'REQUEST'}{'CONTENT'}{'MODULEVERSION'} =
    $FusionInventory::Agent::Task::NetInventory::VERSION;
$result->{'REQUEST'}{'DEVICEID'} = re('^\S+$');

cmp_deeply($content, $result, "expected output");

# Check multi-threading support
my $files = join(" ", map { "--file resources/walks/sample1.walk" } 1..10 ) ;
($out, $err, $rc) = run_executable('fusioninventory-netinventory', "$files --debug --threads 10");
ok($rc == 0, '10 threads started to scan on loopback');
like(
    $out,
    qr/QUERY.*SNMPQUERY/,
    'query output'
);
like(
    $err,
    qr/cleaning 10 worker threads/,
    'cleaning threads reached'
);
