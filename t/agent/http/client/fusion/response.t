#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use JSON::PP;
use English qw(-no_match_vars);
use List::Util qw(first);
use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::HTTP::Client::Fusion;
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

my $client = FusionInventory::Agent::HTTP::Client::Fusion->new(
    logger => $logger
);

# http connection tests
my ($server, $response);

$server = FusionInventory::Test::Server->new(
    port => $port,
);
my $header  = "HTTP/1.0 200 OK\r\n\r\n";
my $json_content  = '{"word":"hello"}';
my $bigkey = "a" x 128;
my $big_json_content  = '{"j":[{"c":[],"f":["'.$bigkey.'"],"a":[{"c":{"e":"xxx"}}],"u":"xxx"}],"f":{"'.$bigkey.'":{"n":"abc","p":1,"d":0,"c":0,"m":["here","there"],"x":["'.$bigkey.'"]}}}';
my $big_decoded = {
    "j" => [
        {
            "c" => [],
            "f" => [ $bigkey ],
            "a" => [
                {
                    "c" => { "e" => "xxx" }
                }
            ],
            "u" => "xxx"
        }
    ],
    "f" => {
        $bigkey => {
            "n" => "abc",
            "p" => 1,
            "d" => 0,
            "c" => 0,
            "m" => [ "here", "there" ],
            "x" => [ $bigkey ]
        }
    }
};
my $html_content = "<html><body>hello</body></html>";
$server->set_dispatch({
    '/error'        => sub { print "HTTP/1.0 403 NOK\r\n\r\n"; },
    '/empty'        => sub { print $header; },
    '/unexpected'   => sub { print $header . $html_content; },
    '/correct'      => sub { print $header . $json_content; },
    '/altered'      => sub { print $header . "\n" . $json_content; },
    '/bigcontent'   => sub { print $header . $big_json_content; },
});
$server->background() or BAIL_OUT("can't launch the server");

subtest "error response" => sub {
    check_response_nok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/error",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
        $logger,
        "[http client] communication error: 403 NOK",
    );
};

subtest "empty content" => sub {
    check_response_nok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/empty",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
        $logger,
        "[http client] Got empty response",
    );
};

subtest "unexpected content" => sub {
    check_response_nok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/unexpected",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
        $logger,
        "[http client] Can't decode JSON content, starting with $html_content",
    );
};

subtest "correct response" => sub {
    check_response_ok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/correct",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
    );
};

subtest "altered response" => sub {
    check_response_ok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/altered",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
    );
};

subtest "big response" => sub {
    check_response_ok(
        scalar $client->send(
            url     => "http://127.0.0.1:$port/bigcontent",
            args    => {
                action    => "getConfig",
                machineid => 'foo',
                task      => {},
            }
        ),
        $big_decoded
    );
};

$server->stop();

sub check_response_ok {
    my ($response, $hash) = @_;

    plan tests => 3;
    ok(defined $response, "response from server");
    isa_ok(
        $response,
        'HASH',
        'response is a hash'
    );
    cmp_deeply(
        $response,
        $hash || { word => 'hello' },
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
