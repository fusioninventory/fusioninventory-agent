#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use XML::TreePP;

use FusionInventory::Test::Utils;

plan tests => 13;

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
ok($rc == 1, 'no controller exit status');
like(
    $err,
    qr/No controllers defined/,
    'no controller stderr'
);
is($out, '', 'no controller stdout');

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

# first inventory
($out, $err, $rc) = run_executable(
    'fusioninventory-agent',
    "--local - --no-category printer,software,environment"
);

subtest "first inventory execution and content" => sub {
    check_content_ok($out);
};

sub check_content_ok {
    my ($out) = @_;

    like(
        $out,
        qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
        'output has correct encoding'
    );

    $content = XML::TreePP->new()->parse($out);
    ok($content, 'output is valid XML');
}
