package FusionInventory::Agent::Transmitter;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Response;

sub new {
    my ($class, $params) = @_;

    die 'no URL in target' unless $params->{url};
    my $url = URI->new($params->{url});
    my $scheme = $url->scheme();
    if (!$scheme) {
        die "no protocol for URL: $params->{url}";
    }
    if ($scheme ne 'http' && $scheme ne 'https') {
        die "invalid protocol for URL: $params->{url}";
    }

    my $self = {
        logger   => $params->{logger},
        user     => $params->{user},
        password => $params->{password},
        URI      => $url
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

    # turns SSL checks on if needed
    if ($scheme eq 'https' && !$params->{'no-ssl-check'}) {
        $self->_turnSSLCheckOn(
            $params->{'ca-cert-file'},
            $params->{'ca-cert-dir'}
        );
        my $host = $url->host();
        $self->{ua}->default_header('If-SSL-Cert-Subject' => "/CN=$host");
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

    my $logger   = $self->{logger};

    # create message
    my $message = $args->{message};
    my $message_content = $self->_compress($message->getContent());
    if (!$message_content) {
        $logger->error('Inflating problem');
        return;
    }

    my $req = HTTP::Request->new(POST => $self->{URI});

    $req->header(
        'Pragma'       => 'no-cache',
        'Content-type' => 'application/x-compress'
    );

    $req->content($message_content);

    # send it
    $logger->debug("sending message");

    my $res = $self->{ua}->request($req);

    # check result
    if (!$res->is_success()) {
        # authentication required
        if ($res->code() == 401) {
            if ($self->{user} && $self->{password}) {
                $logger->debug(
                    "Authentication required, submitting credentials"
                );
                # compute authentication parameters
                my $header = $res->header('www-authenticate');
                my ($realm) = $header =~ /^Basic realm="(.*)"/;
                my $host = $self->{URI}->host();
                my $port = $self->{URI}->port() ||
                   ($self->{URI}->scheme() eq 'https' ? 443 : 80);
                $self->{ua}->credentials(
                    "$host:$port",
                    $realm,
                    $self->{user},
                    $self->{password}
                );
                # replay request
                $res = $self->{ua}->request($req);
                if (!$res->is_success()) {
                    $logger->error($res->message());
                    return;
                }
            } else {
                # abort
                $logger->error(
                    "Authentication required, no credentials available"
                );
                return;
            }
        } else {
            $logger->error($res->message());
            return;
        }
    }


    # create response
    my $response_content;
    if ($res->content()) {
        $response_content = $self->_uncompress($res->content());
        if (!$response_content) {
            $logger->error("Deflating problem");
            return;
        }
    }

    $logger->debug("receiving message: $response_content");

    my $response = FusionInventory::Agent::XML::Response->new({
        content => $response_content,
        logger  => $logger,
    });

    return $response;
}

# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self, $ca_cert_file, $ca_cert_dir) = @_;

    my $logger = $self->{logger};

    eval {
        require Crypt::SSLeay;
    };
    if ($EVAL_ERROR) {
        die 
            "failed to load Crypt::SSLeay, unable to validate SSL certificates";
    }

    if (!$ca_cert_file && !$ca_cert_dir) {
        die
            "neither certificate file or certificate directory given, unable " .
            "to validate SSL certificates";
    }

    if ($ca_cert_file) {
        if (!-f $ca_cert_file && !-l $ca_cert_file) {
            die "--ca-cert-file $ca_cert_file doesn't exist";
        }
        $ENV{HTTPS_CA_FILE} = $ca_cert_file;
    } elsif ($ca_cert_dir) {
        if (!-d $ca_cert_dir) {
            die "--ca-cert-dir $ca_cert_dir doesn't exist";
        }

        $ENV{HTTPS_CA_DIR} = $ca_cert_dir;
    }

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

FusionInventory::Agent::Transmitter - An HTTP message transmitter

=head1 DESCRIPTION

This is the object used by the agent to send messages to OCS or GLPI servers.
by OCS or GLPI servers. It can send messages through HTTP or HTTPS, directly or
through a proxy, and validate SSL certificates.

=head1 METHODS

=head2 new

The constructor. The following arguments are allowed:

=over

=item url (mandatory)

=item logger (mandatory)

=item proxy (default: none)

=item user (default: none)

=item password (default: none)

=item no-ssl-check (default: false)

=item ca-cert-file (default: none)

=item ca-cert-dir (default: none)

=back

=head2 send

Send an instance of C<FusionInventory::Agent::XML::Query> to the target (the
server).
