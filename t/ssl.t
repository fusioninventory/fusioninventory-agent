#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Compress::Zlib;
use English qw(-no_match_vars);
use Socket;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Network;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Test::Server;
use FusionInventory::Logger;

if ($OSNAME eq 'MSWin32' || $OSNAME eq 'darwin') {
    plan skip_all => 'non working test on Windows and MacOS';
} else {
    plan tests => 6;
}

my $ok = sub {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print compress("<REPLY><word>hello</word></REPLY>");
};

my $logger = FusionInventory::Logger->new({
    backends => [ 'Test' ]
});

# no connection tests
BAIL_OUT("port aleady used") if test_port(8080);

my $server;
my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    logger => $logger,
    target => {
        deviceid => 'bar'
    },
    msg => {
        foo => 'bar'
    }
});
my $unsafe_client = FusionInventory::Agent::Network->new({
    logger       => $logger,
    target       => {
        path => 'https://localhost:8080/public'
    },
    config       => {
        VERSION        => 42,
        'no-ssl-check' => 1,
    },
});
my $secure_client = FusionInventory::Agent::Network->new({
    logger       => $logger,
    target       => {
        path => 'https://localhost:8080/public'
    },
    config       => {
        VERSION        => 42,
        'ca-cert-file' => 't/ssl/crt/ca.pem',
    },
});

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
    $secure_client->send({message => $message}),
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
    $secure_client->send({message => $message}),
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
    !$secure_client->send({message => $message}),
    'trusted certificate, wrong hostname: connection failure'
);

ok(
    $unsafe_client->send({message => $message}),
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
    !$secure_client->send({message => $message}),
    'untrusted certificate, correct hostname: connection failure'
);

ok(
    $unsafe_client->send({message => $message}),
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
