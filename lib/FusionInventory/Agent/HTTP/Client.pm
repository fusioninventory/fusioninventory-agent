package FusionInventory::Agent::HTTP::Client;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::XML::Response;

sub new {
    my ($class, %params) = @_;

    die "non-existing certificate file $params{ca_cert_file}"
        if $params{ca_cert_file} && ! -f $params{ca_cert_file};

    die "non-existing certificate directory $params{ca_cert_dir}"
        if $params{ca_cert_dir} && ! -d $params{ca_cert_dir};

    my $self = {
        logger         => $params{logger} ||
                          FusionInventory::Agent::Logger->new(),
        user           => $params{user},
        password       => $params{password},
        ca_cert_file   => $params{ca_cert_file},
        ca_cert_dir    => $params{ca_cert_dir},
        no_ssl_check   => $params{no_ssl_check},
        timeout        => $params{timeout} || 180
    };
    bless $self, $class;

    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1, requests_redirectable => ['POST', 'GET', 'HEAD']);

    if ($params{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $params{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }

    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);
    $self->{ua}->timeout($params{timeout});

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
    my ($self, %params) = @_;

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});
    my $message = $params{message};
    my $logger  = $self->{logger};

    # activate SSL if needed
    my $scheme = $url->scheme();
    if ($scheme eq 'https' && !$self->{no_ssl_check}) {
        $self->_turnSSLCheckOn();
        my $pattern = _getCertificatePattern($url->host());
        $self->{ua}->default_header('If-SSL-Cert-Subject' => $pattern);
    }

    my $request_content = $message->getContent();
    $logger->debug("[client] sending message: $request_content");

    $request_content = $self->_compress($request_content);
    if (!$request_content) {
        $logger->error('[client] inflating problem');
        return;
    }

    my $request = HTTP::Request->new(POST => $url);
    $request->header(
        'Pragma'       => 'no-cache',
        'Content-type' => 'application/x-compress'
    );
    $request->content($request_content);

    my $result;
    eval {
        if ($OSNAME eq 'MSWin32' && $scheme eq 'https') {
            alarm $self->{timeout};
        }
        $result = $self->{ua}->request($request);
        alarm 0;
    };

    # check result first
    if (!$result->is_success()) {
        # authentication required
        if ($result->code() == 401) {
            if ($self->{user} && $self->{password}) {
                $logger->debug(
                    "[client] authentication required, submitting " .
                    "credentials"
                );
                # compute authentication parameters
                my $header = $result->header('www-authenticate');
                my ($realm) = $header =~ /^Basic realm="(.*)"/;
                my $host = $url->host();
                my $port = $url->port() ||
                   ($scheme eq 'https' ? 443 : 80);
                $self->{ua}->credentials(
                    "$host:$port",
                    $realm,
                    $self->{user},
                    $self->{password}
                );
                # replay request
                eval {
                    if ($OSNAME eq 'MSWin32' && $scheme eq 'https') {
                        alarm $self->{timeout};
                    }
                    $result = $self->{ua}->request($request);
                    alarm 0;
                };
                if (!$result->is_success()) {
                    $logger->error(
                        "[client] cannot establish communication with " .
                        "$url: " . $result->status_line()
                    );
                    return;
                }
            } else {
                # abort
                $logger->error(
                    "[client] authentication required, no credentials " .
                    "available"
                );
                return;
            }
        } else {
            $logger->error(
                "[client] cannot establish communication with $url: " .
                $result->status_line()
            );
            return;
        }
    }

    # stop or send in the http's body

    my $response_content = $result->content();

   if (!$response_content) {
        $logger->error("[client] response is empty");
        return;
    }

    $response_content = $self->_uncompress($response_content);
    if (!$response_content) {
        $logger->error("[client] deflating problem");
        return;
    }

    $logger->debug("[client] receiving message: $response_content");

    my $response = FusionInventory::Agent::XML::Response->new(
        content => $response_content
    );

    return $response;
}

# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self) = @_;

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

sub _getCertificatePattern {
    my ($hostname) = @_;

    # Accept SSL cert will hostname with wild-card
    # http://forge.fusioninventory.org/issues/542
    $hostname =~ s/^([^\.]+)/($1|\\*)/;
    # protect metacharacters, as pattern will be evaluated as a regex
    $hostname =~ s/\./\\./g;

    return "CN=$hostname(\$|\/)";
}


sub getStore {
    my ($self, %params) = @_;

    my $source = $params{source};
    my $noProxy = $params{noProxy};

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
    my ($self, %params) = @_;

    my $source = $params{source};
    my $noProxy = $params{noProxy};

    my $response = $self->{ua}->get($source);

    return $response->decoded_content if $response->is_success;

    return;
}


sub isSuccess {
    my ($self, %params) = @_;

    my $code = $params{code};

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

    File::Temp->require();
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

FusionInventory::Agent::HTTP::Client - An HTTP client

=head1 DESCRIPTION

This is the object used by the agent to send messages to OCS or GLPI servers.
by OCS or GLPI servers. It can send messages through HTTP or HTTPS, directly or
through a proxy, and validate SSL certificates.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<proxy>

the URL of an HTTP proxy

=item I<user>

the user for HTTP authentication

=item I<password>

the password for HTTP authentication

=item I<no_ssl_check>

a flag allowing to ignore untrusted server certificates (default: false)

=item I<ca_cert_file>

the file containing trusted certificates

=item I<ca_cert_dir>

the directory containing trusted certificates

=back

=head2 send(%params)

Send an instance of C<FusionInventory::Agent::XML::Query> to the target (the
server).

=head2 getStore(%params)

Acts like LWP::Simple::getstore.

        my $rc = $client->getStore({
                source => 'http://www.FusionInventory.org/',
                target => '/tmp/fusioinventory.html'
                noProxy => 0
            });

$rc, can be read by isSuccess()

=head2 get(%params)

        my $content = $client->get(
                source => 'http://www.FusionInventory.org/',
                timeout => 15,
                noProxy => 0
            );

Act like LWP::Simple::get, return the HTTP content of the URL in 'source'.
The timeout is optional

=head2 isSuccess(%params)

Wrapper for LWP::is_success;

        die unless $client->isSuccess({ code => $rc });
