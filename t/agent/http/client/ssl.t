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

use Net::HTTPS;

# Can help to debug SSL negociation in case of failure
#$Net::SSLeay::trace = 1;

unsetProxyEnvVar();

# find an available port
my $port = first { test_port($_) } 8080 .. 8090;

if (!$port) {
    plan skip_all => 'no available port';
} elsif ($OSNAME eq 'MSWin32') {
    plan skip_all => 'non working test on Windows';
} elsif ($OSNAME eq 'darwin') {
    plan skip_all => 'non working test on MacOS';
} elsif ($LWP::VERSION < 6) {
    plan skip_all => "LWP version too old, skipping";
} else {
    plan tests => 18;
}

diag("LWP\@$LWP::VERSION / LWP::Protocol\@$LWP::Protocol::VERSION / ",
    "IO::Socket\@$IO::Socket::VERSION / IO::Socket::SSL\@$IO::Socket::SSL::VERSION / ",
    "IO::Socket::INET\@$IO::Socket::INET::VERSION / ",
    "Net::SSLeay\@$Net::SSLeay::VERSION / Net::HTTPS\@$Net::HTTPS::VERSION / ",
    "HTTP::Status\@$HTTP::Status::VERSION / HTTP::Response\@$HTTP::Response::VERSION");

my $ok = sub {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print "OK";
};

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

unless (-e "resources/ssl/crt/ca.pem") {
    print STDERR "Generating SSL certificates...\n";
    qx(cd resources/ssl ; ./generate.sh );
}

my $proxy = FusionInventory::Test::Proxy->new();
$proxy->background();

my $server;
my $request;
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

ok($server->background(), "Good server launched in background");

$request = $secure_client->request(HTTP::Request->new(GET => $url));
ok(
    $request->is_success(),
    'trusted certificate, correct hostname: connection success'
);

is(
    IO::Socket::SSL::errstr(), '',
    'No SSL failure using trusted certificate toward good server'
);

SKIP: {
skip "Known to fail, see: http://forge.fusioninventory.org/issues/1940", 1 unless $ENV{TEST_AUTHOR};
$request = $secure_proxy_client->request(HTTP::Request->new(GET => $url));
ok(
    $request->is_success(),
    'trusted certificate, correct hostname, through proxy: connection success'
);
}

SKIP: {
skip "Known to fail, see: http://forge.fusioninventory.org/issues/1940", 1 unless $ENV{TEST_AUTHOR};
is(
    IO::Socket::SSL::errstr(), '',
    'No SSL failure using trusted certificate toward good server through proxy'
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
ok($server->background(), "Server using alternate certs launched in background");

$request = $secure_client->request(HTTP::Request->new(GET => $url));
ok(
    $request->is_success(),
    'trusted certificate, alternate hostname: connection success'
);

is(
    IO::Socket::SSL::errstr(), '',
    'No SSL failure using secure client toward alternate server'
);

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
ok($server->background(), "Server using wrong certs launched in background");

$request = $unsafe_client->request(HTTP::Request->new(GET => $url));
ok(
    $request->is_success(),
    'trusted certificate, wrong hostname, no check: connection success'
);

is(
    IO::Socket::SSL::errstr(), '',
    'No SSL failure using unsafe client toward wrong server'
);

$request = $secure_client->request(HTTP::Request->new(GET => $url));
ok(
    !$request->is_success(),
    'trusted certificate, wrong hostname: connection failure'
);

like(
    $request->status_line,
    qr/certificate verify failed/,
    'SSL failure using trusted certificate toward wrong server'
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
ok($server->background(), "Server using bad certs launched in background");

$request = $unsafe_client->request(HTTP::Request->new(GET => $url));
ok(
    $request->is_success(),
    'untrusted certificate, correct hostname, no check: connection success'
);

is(
    IO::Socket::SSL::errstr(), '',
    'No SSL failure using unsafe client toward bad server'
);

$request = $secure_client->request(HTTP::Request->new(GET => $url));
ok(
    !$request->is_success(),
    'untrusted certificate, correct hostname: connection failure'
);

like(
    $request->status_line,
    qr/certificate verify failed/,
    'SSL failure using trusted certificate toward bad server'
);

$server->stop();
