#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use List::Util qw(first);
use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::XML::Query;
use FusionInventory::Test::Server;
use FusionInventory::Test::Utils;

unsetProxyEnvVar();

# find an available port
my $port = first { test_port($_) } 8080 .. 8090;

if (!$port) {
    plan skip_all => 'no available port';
} else {
    plan tests => 6;
}

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $message = FusionInventory::Agent::XML::Query->new(
    deviceid => 'foo',
    query => 'foo',
    msg => {
        foo => 'foo',
        bar => 'bar'
    },
);

my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
    logger => $logger
);

# http connection tests
my ($server, $response);

$server = FusionInventory::Test::Server->new(
    port => $port,
);
my $header  = "HTTP/1.0 200 OK\r\n\r\n";
my $xml_content  = "<REPLY><word>hello</word></REPLY>";
my $html_content = "<html><body>hello</body></html>";
$server->set_dispatch({
    '/error'        => sub { print "HTTP/1.0 403 NOK\r\n\r\n"; },
    '/empty'        => sub { print $header; },
    '/mixedhtml'   => sub { print $header . $html_content." a aee".$xml_content ; },
    '/unexpected'   => sub { print $header . $html_content; },
    '/correct'      => sub { print $header . $xml_content; },
    '/altered'      => sub { print $header . "\n" . $xml_content; },
});
$server->background() or BAIL_OUT("can't launch the server");

subtest "error response" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/error",
        ),
        $logger,
        "[http client] communication error: 403 NOK",
    );
};

subtest "empty content" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/empty",
        ),
        $logger,
        "[http client] unknown content format",
    );
};


subtest "mixedhtml content" => sub {
    check_response_ok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/mixedhtml",
        ),
    );
};

subtest "unexpected content" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/unexpected",
        ),
        $logger,
        "[http client] unexpected content, starting with $html_content",
    );
};

subtest "correct response" => sub {
    check_response_ok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/correct",
        ),
    );
};

subtest "altered response" => sub {
    check_response_ok(
        scalar $client->send(
            message => $message,
            url     => "http://127.0.0.1:$port/altered",
        ),
    );
};

$server->stop();

sub check_response_ok {
    my ($response) = @_;

    plan tests => 3;
    ok(defined $response, "response from server");
    isa_ok(
        $response,
        'FusionInventory::Agent::XML::Response',
        'response class'
    );
    my $content = $response->getContent();
    cmp_deeply(
        $content,
        { word => 'hello' },
        'response content'
    );
}

sub check_response_nok {
    my ($response, $logger, $message) = @_;

    plan tests => 3;
    ok(!defined $response,  "no response");
    is(
        $logger->{backends}->[0]->{level},
        'error',
        "error message level"
    );
    if (ref $message eq 'Regexp') {
        like(
            $logger->{backends}->[0]->{message},
            $message,
            "error message content"
        );
    } else {
        is(
            $logger->{backends}->[0]->{message},
            $message,
            "error message content"
        );
    }
}
