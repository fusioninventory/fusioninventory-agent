#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use List::Util qw(first);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::HTTP::Client;
use FusionInventory::Test::Proxy;
use FusionInventory::Test::Server;
use FusionInventory::Test::Utils;

unsetProxyEnvVar();

# find an available port
my $port = first { test_port($_) } 8080 .. 8090;

if (!$port) {
    plan skip_all => 'no available port';
} elsif ($OSNAME eq 'MSWin32') {
    plan skip_all => 'non working test on Windows';
} elsif ($OSNAME eq 'darwin') {
    plan skip_all => 'non working test on MacOS';
} else {
    plan tests => 7;
}

my $ok = sub {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print "OK";
};

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $proxy = FusionInventory::Test::Proxy->new();
$proxy->background();

my $server;
my $url = "https://127.0.0.1:$port/public";
my $unsafe_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    no_ssl_check => 1,
);

my $secure_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    ca_cert_file => 'resources/ssl/crt/ca.pem',
);

my $secure_proxy_client = FusionInventory::Agent::HTTP::Client->new(
    logger => $logger,
    proxy  => $proxy->url(),
    ca_cert_file => 'resources/ssl/crt/ca.pem',
);

# ensure the server get stopped even if an exception is thrown
$SIG{__DIE__}  = sub { $server->stop(); };

# trusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => $port,
    ssl      => 1,
    crt      => 'resources/ssl/crt/good.pem',
    key      => 'resources/ssl/key/good.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, correct hostname: connection success'
);

SKIP: {
skip "Known to fail, see: http://forge.fusioninventory.org/issues/1940", 1 unless $ENV{TEST_AUTHOR};
ok(
    $secure_proxy_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, correct hostname, through proxy: connection success'
);
}

$server->stop();
$proxy->stop();

# trusted certificate, alternate hostname
$server = FusionInventory::Test::Server->new(
    port     => $port,
    ssl      => 1,
    crt      => 'resources/ssl/crt/alternate.pem',
    key      => 'resources/ssl/key/alternate.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;


SKIP: {
skip "LWP version too old, skipping", 1 unless $LWP::VERSION >= 6;
ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, alternate hostname: connection success'
);
}

$server->stop();

# trusted certificate, wrong hostname
$server = FusionInventory::Test::Server->new(
    port     => $port,
    ssl      => 1,
    crt      => 'resources/ssl/crt/wrong.pem',
    key      => 'resources/ssl/key/wrong.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname: connection failure'
);

$server->stop();
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname, no check: connection success'
);

$server->stop();

# untrusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => $port,
    ssl      => 1,
    crt      => 'resources/ssl/crt/bad.pem',
    key      => 'resources/ssl/key/bad.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname: connection failure'
);

SKIP: {
$server->stop();
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;
skip "LWP version too old, skipping", 1 unless $LWP::VERSION >= 6;
ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname, no check: connection success'
);
}

$server->stop();
