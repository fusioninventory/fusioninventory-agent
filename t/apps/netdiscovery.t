#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Test::Utils;

plan tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$FusionInventory::Agent::Task::NetDiscovery::VERSION/,
    '--version stdout'
);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery');
ok($rc == 2, 'no address block exit status');
like(
    $err,
    qr/no address block given, aborting/,
    'no address block stderr'
);
is($out, '', 'no target stdout');
