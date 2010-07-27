#!/usr/bin/perl

use strict;

use Apache::TestConfig;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Logger;
use Test::More;
use Test::Exception;

plan tests => 10;

$ENV{LC_ALL} = 'C';

my $network;
throws_ok {
    $network = FusionInventory::Agent::Network->new({});
} qr/^no target/, 'no target';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        target => {}
    });
} qr/^no config/, 'no config';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        target => {},
        config => {},
    });
} qr/^no URI/, 'no URI';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        target => { path => 'foo' },
        config => {},
    });
} qr/^no protocol for URI/, 'no protocol';

throws_ok {
    $network = FusionInventory::Agent::Network->new({
        target => { path => 'xml://foo' },
        config => {},
    });
} qr/^invalid protocol for URI/, 'invalid protocol';

my $logger = FusionInventory::Logger->new({
    config => { logger => 'Test' }
});

lives_ok {
    $network = FusionInventory::Agent::Network->new({
        target => { path => 'http://localhost:8529/test' },
        config => {},
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

my $config = Apache::TestConfig->new(httpd => '/usr/sbin/httpd');
$config->httpd_config();
$config->prepare_t_conf();
$config->generate_httpd_conf;
$config->save;
my $server = $config->server();

ok(!$network->send({ message => $message }), "sending message without server");
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

ok($network->send({ message => $message }), "sending message with server");

$server->stop();
