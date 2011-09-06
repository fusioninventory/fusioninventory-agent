#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use IPC::Run qw(run);

use Test::More tests => 3;

my ($out, $err, $rc);

($out, $err, $rc) = run_injector('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage/,
    '--help'
);
is($out, '', '--help stdin');


sub run_injector {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ $EXECUTABLE_NAME, 'fusioninventory-injector', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}
