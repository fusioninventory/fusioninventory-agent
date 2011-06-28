#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use English qw(-no_match_vars);
use Socket;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::HTTP::Client;
use FusionInventory::Test::Server;

if ($OSNAME eq 'MSWin32' || $OSNAME eq 'darwin') {
    plan skip_all => 'non working test on Windows and MacOS';
} else {
    plan tests => 6;
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

# no connection tests
BAIL_OUT("port aleady used") if test_port(8080);

my $server;
my $url = 'https://localhost:8080/public';
my $unsafe_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    no_ssl_check => 1,
);
my $secure_client = FusionInventory::Agent::HTTP::Client->new(
    logger       => $logger,
    ca_cert_file => 't/ssl/crt/ca.pem',
);

# ensure the server get stopped even if an exception is thrown
$SIG{__DIE__}  = sub { $server->stop(); };

# trusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/good.pem',
    key      => 't/ssl/key/good.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, correct hostname: connection success'
);

$server->stop();

# trusted certificate, alternate hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/alternate.pem',
    key      => 't/ssl/key/alternate.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    $secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, alternate hostname: connection success'
);

$server->stop();

# trusted certificate, wrong hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/wrong.pem',
    key      => 't/ssl/key/wrong.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname: connection failure'
);

ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'trusted certificate, wrong hostname, no check: connection success'
);

$server->stop();

# untrusted certificate, correct hostname
$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 't/ssl/crt/bad.pem',
    key      => 't/ssl/key/bad.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
});
$server->background();

ok(
    !$secure_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname: connection failure'
);

ok(
    $unsafe_client->request(HTTP::Request->new(GET => $url))->is_success(),
    'untrusted certificate, correct hostname, no check: connection success'
);

$server->stop();

sub test_port {
    my $port   = $_[0];

    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');
    if (socket(my $socket, PF_INET, SOCK_STREAM, $proto)) {
        if (connect($socket, $paddr)) {
            close $socket;
            return 1;
        } 
    }

    return 0;
}
