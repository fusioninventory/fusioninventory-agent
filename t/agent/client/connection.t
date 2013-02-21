#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use HTTP::Request;
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

# check than localhost resolves correctly
my $localhost_ok = test_localhost();

if (!$port) {
    plan skip_all => 'no port available';
} else {
    plan tests => 36;
}

my $ok = sub {
    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print "OK";
};

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $client = FusionInventory::Agent::HTTP::Client->new(
    logger => $logger
);


subtest "no response" => sub {
    check_response_nok(
        $client,
        "http://localhost:$port/public",
        $logger,
        qr/Can't connect to localhost:$port/
    );
};

# http connection tests
my ($server, $response);

# ensure the server get stopped even if an exception is thrown
$SIG{__DIE__}  = sub { $server->stop(); };

$server = FusionInventory::Test::Server->new(
    port     => $port,
    user     => 'test',
    realm    => 'test',
    password => 'test',
);
$server->set_dispatch({
    '/public'  => $ok,
    '/private' => sub { return $ok->(@_) if $server->authenticate(); }
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "http://localhost:$port/public"
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger => $logger
    );
} 'instanciation: http, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "http://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user     => 'test',
        password => 'test',
        logger   => $logger,
    );
} 'instanciation:  http, auth, with credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "http://localhost:$port/private"
    );
};

$server->stop();

SKIP: {
skip 'non working test under MacOS', 12 if $OSNAME eq 'darwin';
skip 'non working test under Windows', 12 if $OSNAME eq 'MSWin32';
skip 'localhost resolution failure', 12 if !$localhost_ok;
# https connection tests

$server = FusionInventory::Test::Server->new(
    port     => $port,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 'resources/ssl/crt/good.pem',
    key      => 'resources/ssl/key/good.pem',
);
$server->set_dispatch({
    '/public'  => $ok,
    '/private' => sub { return $ok->(@_) if $server->authenticate(); }
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/public"
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "https://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled, auth, credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/private",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
    );
} 'instanciation: https';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/public",
    ); 
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
    );
} 'instanciation: https, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "https://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
    );
} 'instanciation: https, auth, credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/private",
    );
};

$server->stop();
}

SKIP: {
skip 'non working test under Windows', 18 if $OSNAME eq 'MSWin32';
skip 'localhost resolution failure', 18 if !$localhost_ok;
# http connection through proxy tests

$server = FusionInventory::Test::Server->new(
    port     => $port,
    user     => 'test',
    realm    => 'test',
    password => 'test',
);
$server->set_dispatch({
    '/public'  => sub {
        return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR};
    },
    '/private' => sub {
        return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR} &&
                            $server->authenticate();
    }
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

my $proxy = FusionInventory::Test::Proxy->new();
$proxy->background();

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger => $logger,
        proxy  => $proxy->url()
    );
} 'instanciation: http, proxy';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "http://localhost:$port/public",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger => $logger,
        proxy  => $proxy->url()
    );
} 'instanciation: http, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "http://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    ); 
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user     => 'test',
        password => 'test',
        logger   => $logger,
        proxy    => $proxy->url()
    );
} 'instanciation: http, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "http://localhost:$port/private",
    );
};

$server->stop();

SKIP: {
skip 'non working test under MacOS', 12 if $OSNAME eq 'darwin';
# https connection through proxy tests

$server = FusionInventory::Test::Server->new(
    port     => $port,
    user     => 'test',
    realm    => 'test',
    password => 'test',
    ssl      => 1,
    crt      => 'resources/ssl/crt/good.pem',
    key      => 'resources/ssl/key/good.pem',
);
$server->set_dispatch({
    '/public'  => sub { return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR}; },
    '/private' => sub { return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR} && $server->authenticate(); }
});
eval {
    $server->background();
};
BAIL_OUT("can't launch the server: $EVAL_ERROR") if $EVAL_ERROR;

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, check disabled';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/public",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, check disabled, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "https://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, check disabled, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/private",
    );
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
        proxy        => $proxy->url(),
    );
} 'instanciation: https, proxy';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/public",
    ); 
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        $client,
        "https://localhost:$port/private",
        $logger,
        "[http client] authentication required, no credentials available",
    ); 
};

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        ca_cert_file => 'resources/ssl/crt/ca.pem',
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok(
        $client,
        "https://localhost:$port/private",
    );
};

$server->stop();
}

$proxy->stop();
}

sub check_response_ok {
    my ($client, $url) = @_;

    plan tests => 1;
    my $response = $client->request(HTTP::Request->new(GET => $url));

    ok($response->is_success(), "response is a success");
}

sub check_response_nok {
    my ($client, $url, $logger, $message) = @_;

    plan tests => 3;
    my $response = $client->request(HTTP::Request->new(GET => $url));

    ok(!$response->is_success(), "response is an error");
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
