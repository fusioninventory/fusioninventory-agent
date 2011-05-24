#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use LWP::UserAgent;
use Socket;
use Test::More;
use Test::Exception;

use FusionInventory::Test::Agent;
use FusionInventory::Agent::HTTP::Server;
use FusionInventory::Agent::Logger;

plan tests => 5;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $server;

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent   => FusionInventory::Test::Agent->new(),
        logger  => $logger,
        htmldir => 'share/html'
    );
} 'instanciation with default values: ok';

my $client = LWP::UserAgent->new();

ok(
    $client->get('http://localhost:62354')->is_success(),
    'server listening on default port'
);

lives_ok {
    $server = FusionInventory::Agent::HTTP::Server->new(
        agent   => FusionInventory::Test::Agent->new(),
        logger  => $logger,
        port    => 8080,
        htmldir => 'share/html'
    );
} 'instanciation with specific port: ok';

ok(
    !$client->get('http://localhost:62354')->is_success(),
    'server not listening anymore on default port'
);

ok(
    $client->get('http://localhost:8080')->is_success(),
    'server listening on specific port'
);
