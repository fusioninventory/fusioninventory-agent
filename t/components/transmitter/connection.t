#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Compress::Zlib;
use English qw(-no_match_vars);
use Socket;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Test::Server;
use FusionInventory::Test::Proxy;

if ($OSNAME eq 'MSWin32') {
    plan skip_all => 'non working test on Windows';
} else {
    plan tests => 36;
}

my $ok = sub {
    my ($server, $cgi) = @_;

    print "HTTP/1.0 200 OK\r\n";
    print "\r\n";
    print compress("<REPLY><word>hello</word></REPLY>");
};

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(
    deviceid => 'foo',
    msg => {
        foo => 'foo',
        bar => 'bar'
    },
);

my $transmitter = FusionInventory::Agent::Transmitter->new(
    logger => $logger
);

# no connection tests
BAIL_OUT("port aleady used") if test_port(8080);

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'http://localhost:8080/public',
        ),
        $logger,
        qr/Can't connect to localhost:8080/
    );
};

# http connection tests
my ($server, $response);

# ensure the server get stopped even if an exception is thrown
$SIG{__DIE__}  = sub { $server->stop(); };

$server = FusionInventory::Test::Server->new(
    port     => 8080,
    user     => 'test',
    realm    => 'test',
    password => 'test',
);
$server->set_dispatch({
    '/public'  => $ok,
    '/private' => sub { return $ok->(@_) if $server->authenticate(); }
});
$server->background() or BAIL_OUT("can't launch the server");

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'http://localhost:8080/public',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger => $logger
    );
} 'instanciation: http, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'http://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    );
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user     => 'test',
        password => 'test',
        logger   => $logger,
    );
} 'instanciation:  http, auth, with credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'http://localhost:8080/private',
    ));
};

$server->stop();

SKIP: {
skip 'non working test under MacOS', 12 if $OSNAME eq 'darwin';
# https connection tests

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
    '/private' => sub { return $ok->(@_) if $server->authenticate(); }
});
$server->background();

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/public',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'https://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    );
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        no_ssl_check => 1,
    );
} 'instanciation: https, check disabled, auth, credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/private',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
    );
} 'instanciation: https';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/public',
    )); 
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
    );
} 'instanciation: https, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'https://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    );
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
    );
} 'instanciation: https, auth, credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/private',
    ));
};

$server->stop();
}

# http connection through proxy tests

$server = FusionInventory::Test::Server->new(
    port     => 8080,
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
$server->background();

my $proxy = FusionInventory::Test::Proxy->new();
$proxy->background();

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger => $logger,
        proxy  => $proxy->url()
    );
} 'instanciation: http, proxy';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'http://localhost:8080/public',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger => $logger,
        proxy  => $proxy->url()
    );
} 'instanciation: http, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'http://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    ); 
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user     => 'test',
        password => 'test',
        logger   => $logger,
        proxy    => $proxy->url()
    );
} 'instanciation: http, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'http://localhost:8080/private',
    ));
};

$server->stop();

SKIP: {
skip 'non working test under MacOS', 12 if $OSNAME eq 'darwin';
# https connection through proxy tests

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
    '/public'  => sub { return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR}; },
    '/private' => sub { return $ok->(@_) if $ENV{HTTP_X_FORWARDED_FOR} && $server->authenticate(); }
});
$server->background();

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, check disabled';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/public',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, check disabled, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'https://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    );
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        no_ssl_check => 1,
        proxy        => $proxy->url()
    );
} 'instanciation: https, check disabled, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/private',
    ));
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
        proxy        => $proxy->url(),
    );
} 'instanciation: https, proxy';

subtest "correct response" => sub {
    check_response_ok($response = $transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/public',
    )); 
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, auth, no credentials';

subtest "no response" => sub {
    check_response_nok(
        scalar $transmitter->send(
            message => $message,
            url     => 'https://localhost:8080/private',
        ),
        $logger,
        "[transmitter] authentication required, no credentials available",
    ); 
};

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        user         => 'test',
        password     => 'test',
        logger       => $logger,
        ca_cert_file => 't/ssl/crt/ca.pem',
        proxy        => $proxy->url()
    );
} 'instanciation: https, proxy, auth, credentials';

subtest "correct response" => sub {
    check_response_ok($transmitter->send(
        message => $message,
        url     => 'https://localhost:8080/private',
    ));
};

$server->stop();
}

$proxy->stop();


sub check_response_ok {
    my ($response) = @_;

    plan tests => 3;
    ok(defined $response, "response from server");
    isa_ok(
        $response,
        'FusionInventory::Agent::XML::Response',
        'response class'
    );
    my $content;
    lives_and { $content = $response->getParsedContent()} 'getParsedContent';
    is_deeply(
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
