#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use UNIVERSAL::require;

use FusionInventory::Test::Utils;

FusionInventory::Agent::Task::NetDiscovery->use();

plan tests => 6;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', );
ok($rc == 2, 'no first address exit status');
like(
    $err,
    qr/no network given/,
    'no target stderr'
);
is($out, '', 'no target stdout');
