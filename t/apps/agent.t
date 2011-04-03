#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use IPC::Run qw(run);
use XML::TreePP;

use FusionInventory::Agent::Tools;

use Test::More tests => 13;

my ($out, $err, $rc);

($out, $err, $rc) = run_agent('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage:/,
    '--help stderr'
);
is($out, '', '--help stdin');

($out, $err, $rc) = run_agent('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    '--version stdin'
);


($out, $err, $rc) = run_agent();
ok($rc == 1, 'no target exit status');
like(
    $err,
    qr/No target defined/,
    'no target stderr'
);
is($out, '', 'no target stdin');

$ENV{FOO} = 'bar';
($out, $err, $rc) = run_agent(
    "--stdout --no-ocsdeploy --no-wakeonlan --no-snmpquery --no-netdiscovery"
);
ok($rc == 0, 'exit status');

my $content = XML::TreePP->new()->parse($out);
ok($content, 'output is valid XML');

like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'output has correct encoding'
);

ok(
    (any
        { $_->{KEY} eq 'FOO' && $_->{VAL} eq 'bar' } 
        @{$content->{REQUEST}->{CONTENT}->{ENVS}}
    ),
    'output has expected environment variable'
);


sub run_agent {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ './fusioninventory-agent', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}
