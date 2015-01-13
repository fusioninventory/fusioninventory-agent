#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::Task::WakeOnLan;
use FusionInventory::Test::Utils;

plan tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-wakeonlan', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable(
    'fusioninventory-wakeonlan',
    ''
);
ok($rc == 2, 'no mac address exit status');
like(
    $err,
    qr/no mac address given, aborting/,
    'no mac address stderr'
);
is($out, '', 'no mac address stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-wakeonlan',
    'foo:bar'
);
ok($rc == 0, 'invalid mac address exit status');
like(
    $err,
    qr/invalid MAC address foo:bar, skipping/,
    'invalid mac address stderr'
);
is($out, '', 'invalid mac address stdout');
