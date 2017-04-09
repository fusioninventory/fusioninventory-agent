#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use XML::TreePP;

use FusionInventory::Agent::Tools;
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

my $regconf = $OSNAME eq 'MSWin32' ? keys(%{FusionInventory::Test::Utils::openWin32Registry()}) : 0;

($out, $err, $rc) = run_executable('fusioninventory-agent', $regconf ? '--config none' : undef);
ok($rc == 1, 'no control server exit status');
like(
    $err,
    qr/No control server defined/,
    'no control server stderr'
);
is($out, '', 'no target stdout');

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
