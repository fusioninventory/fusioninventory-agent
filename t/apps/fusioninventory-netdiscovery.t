#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use IPC::Run qw(run);
use XML::TreePP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::NetInventory;

use Test::More tests => 6;

my ($out, $err, $rc);

($out, $err, $rc) = run_app('--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/Options:/,
    '--help stderr'
);
is($err, '', '--help stdin');

($out, $err, $rc) = run_app('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^NetDiscovery task $FusionInventory::Agent::Task::NetInventory::VERSION/,
    '--version stdin'
);

sub run_app {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ $EXECUTABLE_NAME, 'fusioninventory-netdiscovery', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}

sub check_execution_ok {
    my ($client, $url) = @_;

    ok($rc == 0, 'exit status');

    unlike(
        $err,
        qr/module \S+ disabled: failure to load/,
        'no broken module (loading)'
    );

    unlike(
        $err,
        qr/unexpected error in \S+/,
        'no broken module (execution)'
    );

    like(
        $out,
        qr/^<\?xml version="1.0" encoding="UTF-8" \?>/,
        'output has correct encoding'
    );

    my $content = XML::TreePP->new()->parse($out);
    ok($content, 'output is valid XML');
}
