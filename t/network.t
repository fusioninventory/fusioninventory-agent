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

plan tests => 20;

$ENV{LANGUAGE} = 'C';

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
} qr/^no URL/, 'no URL';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        url => 'foo',
    });
} qr/^no protocol for URL/, 'no protocol';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        url => 'xml://foo',
    });
} qr/^invalid protocol for URL/, 'invalid protocol';

my $logger = FusionInventory::Logger->new({
    config => { logger => 'Test' }
});

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url    => "http://127.0.0.1:8080/public",
        logger => $logger
    });
} 'public area access, with all parameters';

my $response = $network->send({ message => $message });
ok(!defined $response,  "no response from server");

is(
    $logger->{backend}->[0]->{level},
    'error',
    "error message level"
); 
is(
    $logger->{backend}->[0]->{message},
    "Can't connect to 127.0.0.1:8080 (connect: Connection refused)",
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
ok(defined $response, "response from server");
isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response of expected class'
);

# authenticated access
lives_ok {
    $network = FusionInventory::Agent::Network->new({
        url    => "http://127.0.0.1:8080/private",
        logger => $logger
    });
} 'private area access, without authentication parameters';

my $response = $network->send({ message => $message });
ok(!defined $response, "no response from server");

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
} 'private area access, with authentication parameters';

my $response = $network->send({ message => $message });
ok(defined $response, "response from server");
isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response of expected class'
);

my $network_ssl;
throws_ok {
    $network_ssl = FusionInventory::Agent::Network->new({
        url    => 'https://127.0.0.1:8080/private',
        logger => $logger
    });
} qr/^neither certificate file or certificate directory given/, 'https URI without checking parameters';

lives_ok {
    $network_ssl = FusionInventory::Agent::Network->new({
        url    => 'https://127.0.0.1:8080/private',
        logger => $logger,
        'no-ssl-check' => 1,
    });
} 'https URI with no-ssl-check parameter';

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

my $signal = ($^O eq 'MSWin32') ? 9 : 15;
my $nprocesses = kill $signal, $pid;
