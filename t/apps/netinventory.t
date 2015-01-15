#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::Deep;
use Test::More;
use XML::TreePP;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Test::Utils;

plan tests => 11;

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

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    ''
);
ok($rc == 2, 'no target exit status');
like(
    $err,
    qr/no host given, aborting/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    'file:resources/walks/sample4.walk'
);
ok($rc == 0, 'success exit status');

my $content = XML::TreePP->new()->parse($out);
ok($content, 'valid output');

my $result = XML::TreePP->new()->parsefile('resources/walks/sample4.result');
$result->{'REQUEST'}{'CONTENT'}{'MODULEVERSION'} =
    $FusionInventory::Agent::VERSION;
$result->{'REQUEST'}{'DEVICEID'} = re('^\S+$');
cmp_deeply($content, $result, "expected output");

my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    "--target $tmpdir file:resources/walks/sample4.walk"
);
ok($rc == 0, 'success exit status');
ok(-f "$tmpdir/netinventory_sample4.walk.xml", "result file presence");
