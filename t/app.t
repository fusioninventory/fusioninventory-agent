#!/usr/bin/perl -w

use strict;

use English qw(-no_match_vars);
use IPC::Run qw(run);
use XML::TreePP;

use Test::More tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_agent('--version');
ok($rc == 0, 'exit status');
is($err, '', 'stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    'stdin'
);

($out, $err, $rc) = run_agent('--help');
ok($rc == 2, 'exit status');
like(
    $err,
    qr/^Usage:/,
    'stderr'
);
is($out, '', 'stdin');

$ENV{LC_ALL}='AAA';
($out, $err, $rc) = run_agent('--stdout');
ok($rc == 0, 'exit status');
like(
    $out,
    qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
    'XML encoding'
);
my $tpp = XML::TreePP->new();
my $h = $tpp->parse($out);
my $found = 0;
foreach (@{$h->{REQUEST}{CONTENT}{ENVS}}) {
    next unless $_->{KEY} eq 'LC_ALL';
    ok($_->{VAL} eq 'AAA', 'XML content');
    $found = 1;
    last;
}
if (!$found) {
    ko($found == 0, 'XML content');
}

sub run_agent {
    run(
        [ $EXECUTABLE_NAME, qw/ -I lib fusioninventory-agent/, @_ ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}
