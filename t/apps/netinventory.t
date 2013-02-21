#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use XML::TreePP;

use Test::More tests => 15;

use FusionInventory::Agent::Task::NetInventory;
use FusionInventory::Test::Utils;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netinventory', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netinventory', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$FusionInventory::Agent::Task::NetInventory::VERSION/,
    '--version stdin'
);

($out, $err, $rc) = run_executable('fusioninventory-netinventory', );
ok($rc == 2, 'no model exit status');
like(
    $err,
    qr/no model/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory', "--model foobar"
);
ok($rc == 2, 'invalid model exit status');
like(
    $err,
    qr/invalid file/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable(
    'fusioninventory-netinventory',
    '--file resources/walks/sample4.walk --model resources/models/sample1.xml'
);
ok($rc == 0, 'success exit status');

my $content = XML::TreePP->new()->parse($out);
ok($content, 'valid output');

my $result = XML::TreePP->new()->parsefile('resources/walks/sample4.result');
is_deeply($content, $result, "expected output");
