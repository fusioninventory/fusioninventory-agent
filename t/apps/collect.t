#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::Task::Collect;
use FusionInventory::Test::Utils;

plan tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-collect', '--help');
ok($rc == 0, '--help exit status');
is($err, '', '--help stderr');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);

($out, $err, $rc) = run_executable('fusioninventory-collect', '');
ok($rc == 2, 'no job exit status');
like(
    $err,
    qr/^no job given, aborting/,
    'no job stderr'
);
is($out, '', 'no job stdout');

($out, $err, $rc) = run_executable('fusioninventory-collect', 'function:findFile,uuid:foo');
ok($rc == 0, 'simple job exit status');
is($err, '', 'simple job stderr');
ok(is_json_stream($out), 'simple job stdout');
