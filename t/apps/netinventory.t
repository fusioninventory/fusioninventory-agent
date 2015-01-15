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

plan tests => 16;

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
ok($rc == 2, 'no host exit status');
like(
    $err,
    qr/no host given, aborting/,
    'no host stderr'
);
is($out, '', 'no host stdout');

my $expected_result =
    XML::TreePP->new()->parsefile('resources/walks/sample4.result');
$expected_result->{'REQUEST'}{'CONTENT'}{'MODULEVERSION'} =
    $FusionInventory::Agent::VERSION;
$expected_result->{'REQUEST'}{'DEVICEID'} = re('^\S+$');

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    'file:resources/walks/sample4.walk'
);
ok($rc == 0, 'host inventory exit status');
is($err, '', 'host inventory stderr');

my $stdout_result = XML::TreePP->new()->parse($out);
ok($stdout_result, 'result syntax');
cmp_deeply($stdout_result, $expected_result, 'result content');

my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    "--target $tmpdir file:resources/walks/sample4.walk"
);
ok($rc == 0, 'host inventory with file target exit status');
is($err, '', 'host inventory with file target stderr');
is($out, '', 'host inventory with file target stout');

my $result_file = "$tmpdir/netinventory_sample4.walk.xml";
ok(-f $result_file, 'result file presence');
my $file_result = XML::TreePP->new()->parsefile($result_file);
ok($file_result, 'result file syntax');
cmp_deeply($file_result, $expected_result, 'result file content');
