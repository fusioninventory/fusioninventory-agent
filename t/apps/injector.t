#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Test::More tests => 3;

use FusionInventory::Test::Utils;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-injector', '--help');
ok($rc == 0, '--help exit status');
is($err, '', '--help stderr');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
