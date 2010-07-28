#!/usr/bin/perl

use strict;

use Cwd;
use Apache::TestConfig;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Logger;
use Test::More;
use Test::Exception;

plan tests => 13;

$ENV{LANGUAGE} = 'C';

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
        url    => 'http://localhost:8529/test',
        logger => $logger
    });
} 'parameters OK';

my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
    target => { deviceid =>  'foo' },
    msg => {
        foo => 'foo',
        bar => 'bar'
    },
});

my $config = Apache::TestConfig->new(
    httpd => '/usr/sbin/httpd',
    t_dir => getcwd() . '/t/httpd'
);
$config->httpd_config();
$config->prepare_t_conf();
$config->generate_httpd_conf;
$config->save;
my $server = $config->server();

# ensure server is not running
$server->stop();

my $response = $network->send({ message => $message });
ok(!defined $response,  "sending a message with no server");

is(
    $logger->{backend}->[0]->{level},
    'error',
    "error message level"
); 
is(
    $logger->{backend}->[0]->{message},
    "Can't connect to localhost:8529 (connect: Connection refused)",
    "error message content"
); 

# start server
$server->start();

my $response = $network->send({ message => $message });
ok(defined $response, "sending a message to server");
isa_ok(
    $response,
    'FusionInventory::Agent::XML::Response',
    'response of expected class'
);

$server->stop();

my $network_ssl;
throws_ok {
    $network_ssl = FusionInventory::Agent::Network->new({
        url    => 'https://localhost:8529/test',
        logger => $logger
    });
} qr/^neither certificate file or certificate directory given/, 'https URI without checking parameters';

lives_ok {
    $network_ssl = FusionInventory::Agent::Network->new({
        url    => 'https://localhost:8529/test',
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
