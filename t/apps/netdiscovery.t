#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use File::Temp qw(tempdir);
use Test::More;
use UNIVERSAL::require;

use FusionInventory::Test::Utils;

use FusionInventory::Agent::Tools;

plan(skip_all => 'Net::NBName required')
    unless Net::NBName->require();

plan(skip_all => 'nmap command unavailable')
    unless canRun("nmap");

plan tests => 14;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery');
ok($rc == 2, 'no first address exit status');
like(
    $err,
    qr/no network given/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '127.0.0.1/32');
ok($rc == 0, 'localhost discovery exit status');
is($err, '', 'localhost discovery stderr');
ok(is_xml_string($out), 'localhost discovery stdout');

my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);

($out, $err, $rc) = run_executable(
    'fusioninventory-netdiscovery',
    "--target $tmpdir 127.0.0.1/32"
);
ok($rc == 0, 'localhost discovery with file target exit status');
is($err, '', 'localhost discovery with file target stderr');
is($out, '', 'localhost discovery with file target stdout');

my $result_file = "$tmpdir/netdiscovery_127.0.0.1.xml";
ok(-f $result_file, 'result file presence');
ok(is_xml_file($result_file), 'result file syntax');
