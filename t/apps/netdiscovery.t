#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use UNIVERSAL::require;
use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Test::Utils;

# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

FusionInventory::Agent::Task::NetDiscovery->use();

plan tests => 15;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$FusionInventory::Agent::Task::NetDiscovery::VERSION/,
    '--version stdout'
);

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', );
ok($rc == 2, 'no first address exit status');
like(
    $err,
    qr/no first address/,
    'no target stderr'
);
is($out, '', 'no target stdout');

($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--first 192.168.0.1');
ok($rc == 2, 'no last address exit status');
like(
    $err,
    qr/no last address/,
    'no target stderr'
);
is($out, '', 'no target stdout');

SKIP: {
    skip "nmap required", 3 unless canRun("nmap");

    # Check multi-threading support
    ($out, $err, $rc) = run_executable('fusioninventory-netdiscovery', '--first 127.0.0.1 --last 127.0.0.10 --debug --threads 10');
    ok($rc == 0, '10 threads started to scan loopback');
    like(
        $out,
        qr/QUERY.*NETDISCOVERY/,
        'query output'
    );
    like(
        $err,
        qr/cleaning 10 worker threads/,
        'cleaning threads reached'
    );
}
