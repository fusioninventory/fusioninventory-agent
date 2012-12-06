#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Config;
use English qw(-no_match_vars);
use List::Util qw(first);
use LWP::UserAgent;
use Socket;
use Test::More;
use Test::Exception;
use UNIVERSAL::require;

use FusionInventory::Agent::Logger;
use FusionInventory::Test::Agent;
use FusionInventory::Test::Utils;

# check thread support availability
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
} else {
    FusionInventory::Agent::HTTP::Server->use();
    plan tests => 14;
}

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $scheduler = FusionInventory::Agent::Scheduler->new(
);

my $server;

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        htmldir   => 'share/html'
    );
} 'instanciation with default values: ok';

my $client = LWP::UserAgent->new(timeout => 2);

ok(
    $client->get('http://localhost:62354')->is_success(),
    'server listening on default port'
);

ok (
    !$server->_is_trusted('127.0.0.1'),
    'server not trusting 127.0.0.1 address'
);

$server->terminate();

# find an available port
my $port = first { test_port($_) } 8080 .. 8090;

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        htmldir   => 'share/html',
        trust     => [ '127.0.0.1', '192.168.0.0/24' ]
    );
} 'instanciation with a list of trusted address: ok';

ok (
    $server->_is_trusted('127.0.0.1'),
    'server trusting 127.0.0.1 address'
);

ok (
    $server->_is_trusted('192.168.0.1'),
    'server trusting 192.168.0.1 address'
);

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        htmldir   => 'share/html',
        trust     => [ '127.0.0.1', 'localhost', 'th1sIsNowh3re' ]
    );
} 'instanciation with a list of trusted address: ok';

ok (
    $server->_is_trusted('127.0.0.1'),
    'server trusting localhost address'
);

ok (
    !$server->_is_trusted('1.2.3.4'),
    'do not trust unknown host 1.2.3.4'
);

$server->terminate();

# find an available port
$port = first { test_port($_) } 8080 .. 8090;

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent     => FusionInventory::Test::Agent->new(),
        scheduler => $scheduler,
        logger    => $logger,
        port      => $port,
        htmldir   => 'share/html',
    );
} 'instanciation with specific port: ok';
sleep 1;

ok(
    !$client->get('http://localhost:62354')->is_success(),
    'server not listening anymore on default port'
);

ok(
    $client->get("http://localhost:$port")->is_success(),
    'server listening on specific port'
);

# fork a child process, as when running in server mode
if (my $pid = fork()) {
    # parent
    waitpid($pid, 0);
} else {
    # child
    exit(0);
}

ok(
    $client->get("http://localhost:$port")->is_success(),
    'server still listening after child process exit'
);

# fork a child process, and raise ALRM from it, as when a timeout is reached
if (my $pid = fork()) {
    # parent
    waitpid($pid, 0);
} else {
    # child
    alarm 1;
    exit(0);
}

ok(
    $client->get("http://localhost:$port")->is_success(),
    'server still listening after child process raised ALRM'
);

$server->terminate();
