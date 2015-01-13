#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::Task::ESX;
use FusionInventory::Test::Utils;

plan tests => 6;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-esx', '--help');
ok($rc == 0, '--help exit status');
is($err, '', '--help stderr');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);

($out, $err, $rc) = run_executable( 'fusioninventory-esx', '');
ok($rc == 2, 'no host exit status');
like(
    $err,
    qr/no host given, aborting/,
    'no host stderr'
);
is($out, '', 'no host stdout');
