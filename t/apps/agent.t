#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Test::Utils;

plan tests => 12;

my ($content, $out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-agent', '--help');
ok($rc == 0, '--help exit status');
is($err, '', '--help stderr');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);

($out, $err, $rc) = run_executable('fusioninventory-agent', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory Agent/,
    '--version stdout'
);

($out, $err, $rc) = run_executable('fusioninventory-agent', );
ok($rc == 1, 'no server exit status');
like(
    $err,
    qr/no server defined/,
    'no server stderr'
);
is($out, '', 'no server stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-agent',
    '--config none --conf-file /foo/bar'
);
ok($rc == 1, 'incompatible options exit status');
like(
    $err,
    qr/don't use --conf-file/,
    'incompatible options stderr'
);
is($out, '', 'incompatible options stdout');
