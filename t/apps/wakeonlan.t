#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Test::More tests => 6;

use FusionInventory::Agent::Task::WakeOnLan;
use FusionInventory::Test::Utils;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-wakeonlan', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-wakeonlan', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$FusionInventory::Agent::Task::WakeOnLan::VERSION/,
    '--version stdout'
);
