package FusionInventory::Agent::Network;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::XML::Response;

sub new {
    my ($class, $params) = @_;

    die "no url parameter" unless $params->{url};

    die "non-existing certificate file $params->{ca_cert_file}"
        if $params->{ca_cert_file} && ! -f $params->{ca_cert_file};

    die "non-existing certificate directory $params->{ca_cert_dir}"
        if $params->{ca_cert_dir} && ! -d $params->{ca_cert_dir};

    my $self = {
        logger         => $params->{logger},
        user           => $params->{user},
        password       => $params->{password},
        realm          => $params->{realm},
        ca_cert_file   => $params->{ca_cert_file},
        ca_cert_dir    => $params->{ca_cert_dir},
        no_ssl_check   => $params->{no_ssl_check},
        url            => $params->{url},
        timeout        => $params->{timeout} || 180
    };
    bless $self, $class;

    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1);

    if ($params->{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $params->{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }

    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);
    $self->{ua}->timeout($params->{timeout});

    # activate SSL if needed
    my $scheme = $self->{url}->scheme();
    if ($scheme eq 'https' && !$self->{no_ssl_check}) {
        $self->_turnSSLCheckOn();
        my $pattern = _getCertificateRegexp($self->{url}->host());
        $self->{ua}->default_header('If-SSL-Cert-Subject' => $pattern);
    }

    # check compression mode
    if (Compress::Zlib->require()) {
        $self->{compression} = 'native';
        $self->{logger}->debug(
            'Using Compress::Zlib for compression'
        );
    } elsif (can_run('gzip')) {
        $self->{compression} = 'gzip';
        $self->{logger}->debug(
            'Using gzip for compression (server minimal version 1.02 needed)'
        );
    } else {
        $self->{compression} = 'none';
        $self->{logger}->debug(
            'Not using compression (server minimal version 1.02 needed)'
        );
    }

    return $self;
}

sub send {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    my $message = $args->{message};

    my $req = HTTP::Request->new(POST => $self->{url});

    $req->header(
        'Pragma'       => 'no-cache',
        'Content-type' => 'application/x-compress'
    );

    $logger->debug ("sending XML");

    # Print the XMLs in the debug output
    #$logger->debug ("sending: ".$message->getContent());

    my $message_content = $self->_compress($message->getContent());
    if (!$message_content) {
        $logger->error('Inflating problem');
        return;
    }

    $req->content($message_content);

    my $res;
    eval {
        if ($^O =~ /^MSWin/ && $self->{url} =~ /^https:/g) {
            alarm $self->{timeout};
        }
        $res = $self->{ua}->request($req);
        alarm 0;
    };


    my $serverRealm;
    if ($res->code == '401' && $res->header('www-authenticate') =~ /^Basic realm="(.*)"/ && !$self->{realm}) {
        $serverRealm = $1;
        $logger->debug("Basic HTTP Auth: fixing the realm to '$serverRealm' and retrying.");
        my $scheme = $self->{url}->scheme();
        my $host   = $self->{url}->host();
        my $port   = $self->{url}->port() ||
           ($scheme eq 'https' ? 443 : 80);

       $self->{ua}->credentials(
            "$host:$port",
            $serverRealm,
            $self->{user},
            $self->{password}
        );

        eval {
            if ($^O =~ /^MSWin/ && $self->{url} =~ /^https:/g) {
                alarm $self->{timeout};
            }
            $res = $self->{ua}->request($req);
            alarm 0;
        }
    }

    # Checking if connected
    if(!$res->is_success) {
        $logger->error ('Cannot establish communication with `'.
            $self->{url}.': '.
            $res->status_line.'`');
        return;
    }

    # Ok we found the correct realm. We store it.
    $self->{realm} = $serverRealm if $serverRealm;

    # stop or send in the http's body

    my $response_content;

   if (!$res->content()) {
        $logger->error("Response is empty");
        return;
    }

    $response_content = $self->_uncompress($res->content());
    if (!$response_content) {
        $logger->error("Deflating problem");
        return;
    }

    $logger->debug("receiving message: $response_content");

    my $response = FusionInventory::Agent::XML::Response->new({
        content => $response_content
    });

    return $response;
}

# No POD documentation here, it's an internal fuction
# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self, $args) = @_;

    eval {
        require Crypt::SSLeay;
    };
    if ($EVAL_ERROR) {
        die "failed to load Crypt::SSLeay, unable to validate SSL certificates";
    }

    SWITCH: {
        if ($self->{ca_cert_file}) {
            $ENV{HTTPS_CA_FILE} = $self->{ca_cert_file};
            last SWITCH;
        }
        if ($self->{ca_cert_dir}) {
            $ENV{HTTPS_CA_DIR} = $self->{ca_cert_dir};
            last SWITCH;
        }
        die
            "neither certificate file or certificate directory given, unable " .
            "to validate SSL certificates";
    }
}

sub _getCertificateRegexp {
    my ($hostname) = @_;

    # Accept SSL cert will hostname with wild-card
    # http://forge.fusioninventory.org/issues/542
    $hostname =~ s/^([^\.]+)/($1|\\*)/;
    # protect metacharacters, as $re will be evaluated as a regex
    $hostname =~ s/\./\\./g;

    return qr/CN=$hostname($|\/)/;
}


sub getStore {
    my ($self, $args) = @_;

    my $source = $args->{source};
    my $noProxy = $args->{noProxy};

    my $response;
    eval {
        if ($^O =~ /^MSWin/ && $source =~ /^https:/g) {
            alarm $self->{timeout};
        }

        my $request = HTTP::Request->new(GET => $source);
        $response = $self->{ua}->request($request);
        alarm 0;
    };

    return $response->code;

}

sub get {
    my ($self, $args) = @_;

    my $source = $args->{source};
    my $noProxy = $args->{noProxy};

    my $response = $self->{ua}->get($source);

    return $response->decoded_content if $response->is_success;

    return;
}


sub isSuccess {
    my ($self, $args) = @_;

    my $code = $args->{code};

    return is_success($code);

}

sub _compress {
    my ($self, $data) = @_;

    return 
        $self->{compression} eq 'native' ? $self->_compressNative($data) :
        $self->{compression} eq 'gzip'   ? $self->_compressGzip($data)   :
                                          $data;
}

sub _uncompress {
    my ($self, $data) = @_;

    return 
        $self->{compression} eq 'native' ? $self->_uncompressNative($data) :
        $self->{compression} eq 'gzip'   ? $self->_uncompressGzip($data)   :
                                          $data;
}

sub _compressNative {
    my ($self, $data) = @_;

    return Compress::Zlib::compress($data);
}

sub _compressGzip {
    my ($self, $data) = @_;

    my $in = File::Temp->new();
    print $in $data;
    close $in;

    my $command = 'gzip -c ' . $in->filename();
    my $out;
    if (! open $out, '-|', $command) {
        $self->{logger}->debug("Can't run $command: $ERRNO");
        return;
    }

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $result = <$out>;
    close $out;

    return $result;
}

sub _uncompressNative {
    my ($self, $data) = @_;

    return Compress::Zlib::uncompress($data);
}

sub _uncompressGzip {
    my ($self, $data) = @_;

    my $in = File::Temp->new();
    print $in $data;
    close $in;

    my $command = 'gzip -dc ' . $in->filename();
    my $out;
    if (! open $out, '-|', $command) {
        $self->{logger}->debug("Can't run $command: $ERRNO");
        return;
    }

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $result = <$out>;
    close $out;

    return $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Network - the Network abstraction layer

=head1 DESCRIPTION

This module is the abstraction layer for network interaction. It uses LWP.

=head1 METHODS

=head2 new()

The constructor. These keys are expected: config, logger, target.

        my $network = FusionInventory::Agent::Network->new ({

                logger => $logger,
                config => $config,
                target => $target,

            });

=head2 send()

Send an instance of FusionInventory::Agent::XML::Query::* to the target (the
server).

=head2 getStore()

Acts like LWP::Simple::getstore.

        my $rc = $network->getStore({
                source => 'http://www.FusionInventory.org/',
                target => '/tmp/fusioinventory.html'
                noProxy => 0
            });

$rc, can be read by isSuccess()

=head2 get()

        my $content = $network->get({
                source => 'http://www.FusionInventory.org/',
                timeout => 15,
                noProxy => 0
            });

Act like LWP::Simple::get, return the HTTP content of the URL in 'source'.
The timeout is optional

=head2 isSuccess()

Wrapper for LWP::is_success;

        die unless $network->isSuccess({ code => $rc });
