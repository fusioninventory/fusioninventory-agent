#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use IPC::Run qw(run);
use XML::TreePP;

use Test::More tests => 21;

my ($out, $err, $rc);

($out, $err, $rc) = run_worker('--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/^FusionInventory unified agent for UNIX, Linux and MacOSX/,
    '--version stdin'
);

($out, $err, $rc) = run_worker('--help');
ok($rc == 2, '--help exit status');
like(
    $err,
    qr/^Usage:/,
    '--help stderr'
);
is($out, '', '--help stdin');

($out, $err, $rc) = run_worker();
ok($rc == 2, 'no task exit status');
like(
    $err,
    qr/^No task given, aborting/,
    'no task stderr'
);
is($out, '', 'no task stdin');

($out, $err, $rc) = run_worker("--task inventory");
ok($rc == 2, 'no target exit status');
like(
    $err,
    qr/^No target given, aborting/,
    'no target stderr'
);
is($out, '', 'no target stdin');

($out, $err, $rc) = run_worker("--task inventory --target stdout");
ok($rc == 2, 'non-existing target exit status');
like(
    $err,
    qr/No type for target stdout/,
    'non-existing target stderr'
);
is($out, '', 'non-existing target stdin');

my $config;
$config = get_configuration_file(<<EOF);
[stdout]
type = stdout
format = xml
EOF

($out, $err, $rc) = run_worker(
    " --conf-file $config --task inventory --target stdout"
);
ok($rc == 2, 'non-existing task exit status');
like(
    $err,
    qr/No type for task inventory/,
    'non-existing target stderr'
);
is($out, '', 'non-existing task stdin');

$config = get_configuration_file(<<EOF);
[stdout]
type = stdout
format = xml
[inventory]
type = inventory
EOF

$ENV{LC_ALL} = 'AAA';
($out, $err, $rc) = run_worker(
    "--conf-file $config --target stdout --task inventory"
);
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

sub run_worker {
    my ($args) = @_;
    my @args = $args ? split(/\s+/, $args) : ();
    run(
        [ './fusioninventory-worker', @args ],
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
