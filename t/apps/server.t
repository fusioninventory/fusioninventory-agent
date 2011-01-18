#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use IPC::Run qw(run);

use Test::More tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_server('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    '--version stdin'
);

($out, $err, $rc) = run_server('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage:/,
    '--help stderr'
);
is($out, '', '--help stdin');

($out, $err, $rc) = run_server();
ok($rc == 2, 'no jobs exit status');
like(
    $err,
    qr/No jobs defined, aborting/,
    'no jobs stderr'
);
is($out, '', 'no jobs stdin');

sub run_server {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ './fusioninventory-server', @args ],
        \my ($in, $out, $err)
    );
    return ($out, $err, $CHILD_ERROR >> 8);
}

sub get_configuration_file {
    my ($content) = @_;

    my $temp = File::Temp->new(UNLINK => 1);
    print $temp $content;
    close $temp;

    return $temp;
}
