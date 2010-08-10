#!/usr/bin/perl

use strict;
use lib 't';

use FusionInventory::Agent::Network;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Logger;
use FusionInventory::Test::Server;
use Test::More;
use Test::Exception;
use Compress::Zlib;

plan tests => 29;

my $server = FusionInventory::Test::Server->new(
    port => 8080,
    user => 'test',
    realm => 'test',
    password => 'test',
);
$server->set_dispatch( {
    '/public'   => \&public,
    '/private' => \&private,
} );

my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    target => { deviceid =>  'foo' },
    msg => {
        foo => 'foo',
        bar => 'bar'
    },
});

# instanciations tests

my $network;
throws_ok {
    $network = FusionInventory::Agent::Network->new({});
} qr/^no URL/,
'instanciation without URL';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        url => 'foo',
    });
} qr/^no protocol for URL/,
'instanciation without protocol';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        url => 'xml://foo',
    });
} qr/^invalid protocol for URL/,
'instanciation with an invalid protocol';

my $logger = FusionInventory::Logger->new({
    config => { logger => 'Test' }
});

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url    => "http://127.0.0.1:8080/public",
        logger => $logger
    });
} 'instanciation';

my $response = $network->send({ message => $message });
ok(!defined $response,  "no response from non-running server");

is(
    $logger->{backend}->[0]->{level},
    'error',
    "error message level"
); 
like(
    $logger->{backend}->[0]->{message},
    qr/^Can't connect to 127.0.0.1:8080/,
    "error message content"
);

sub public {
    my ($server, $cgi) = @_;
    return response($server, $cgi);
}

sub private {
    my ($server, $cgi) = @_;
    return response($server, $cgi) if $server->authenticate();
}

sub response {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print compress("hello");
}

my $pid = $server->background();

my $response = $network->send({ message => $message });
ok(defined $response, "correct response from server");

isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response class'
);

# authenticated access
lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url    => "http://127.0.0.1:8080/private",
        logger => $logger
    });
} 'instanciation for restricted area';

my $response = $network->send({ message => $message });
ok(!defined $response, "denial response from server");

is(
    $logger->{backend}->[0]->{level},
    'error',
    "error message level"
); 
is(
    $logger->{backend}->[0]->{message},
    "Authentication required",
    "error message content"
); 

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url      => "http://127.0.0.1:8080/private",
        realm    => 'Authorized area',
        user     => 'test',
        password => 'test',
        logger   => $logger,
    });
} 'instanciation for restricted area with credentials';

my $response = $network->send({ message => $message });
ok(defined $response, "correct response from server");

isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response class'
);

$server->stop();

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        url    => 'https://127.0.0.1:8080/public',
        logger => $logger
    });
} qr/^neither certificate file or certificate directory given/,
'instanciation with https URL without certificates';

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url            => 'https://127.0.0.1:8080/public',
        logger         => $logger,
        'no-ssl-check' => 1,
    });
} 'instanciation with https URL with check disabled';

my $server_ssl = FusionInventory::Test::Server->new(
    port => 8080,
    user => 'test',
    realm => 'test',
    password => 'test',
    ssl => 1,
    crt => 't/httpd/conf/ssl/crt/good.pem',
    key => 't/httpd/conf/ssl/key/good.pem',
);
$server_ssl->set_dispatch( {
    '/public'   => \&public,
    '/private' => \&private,
} );
my $pid_ssl = $server_ssl->background();

my $response = $network->send({ message => $message });
ok(defined $response, "correct response from server");

isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response class'
);

# authenticated access
lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url            => "https://127.0.0.1:8080/private",
        logger         => $logger,
        'no-ssl-check' => 1,
    });
} 'instanciation for restricted area';

my $response = $network->send({ message => $message });
ok(!defined $response, "denial response from server");

is(
    $logger->{backend}->[0]->{level},
    'error',
    "error message level"
); 
is(
    $logger->{backend}->[0]->{message},
    "Authentication required",
    "error message content"
); 

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url            => "https://127.0.0.1:8080/private",
        realm          => 'Authorized area',
        user           => 'test',
        password       => 'test',
        logger         => $logger,
        'no-ssl-check' => 1,
    });
} 'instanciation for restricted area with credentials';

my $response = $network->send({ message => $message });
ok(defined $response, "correct response from server");

isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response class'
);

$server_ssl->stop();

my $data = "this is a test";
is(
    $network->_uncompressNative($network->_compressNative($data)),
    $data,
    'round-trip compression with Compress::Zlib'
);

is(
    $network->_uncompressGzip($network->_compressGzip($data)),
    $data,
    'round-trip compression with Gzip'
);

