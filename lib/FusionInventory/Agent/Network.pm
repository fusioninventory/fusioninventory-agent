package FusionInventory::Agent::Network;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;
use URI;

sub new {
    my ($class, $params) = @_;

    die 'no target' unless $params->{target};

    die 'no URI in target' unless $params->{target}->{path};
    my $uri = URI->new($params->{target}->{path});
    my $scheme = $uri->scheme();
    if (!$scheme) {
        die "no protocol for URI: $params->{target}->{path}";
    }
    if ($scheme ne 'http' && $scheme ne 'https') {
        die "invalid protocol for URI: $params->{target}->{path}";
    }
    my $host   = $uri->host();
    my $port   = $uri->port() ||
                 $scheme eq 'https' ? 443 : 80;

    my $self = {
        logger => $params->{logger},
        target => $params->{target},
        URI    => $uri
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

    $self->{ua}->credentials(
        "$host:$port",
        $params->{realm},
        $params->{user},
        $params->{password}
    );

    # turns SSL checks on if needed
    if ($scheme eq 'https' && !$params->{'no-ssl-check'}) {
        $self->_turnSSLCheckOn(
            $params->{'ca-cert-file'},
            $params->{'ca-cert-dir'}
        );
        $self->{ua}->default_header('If-SSL-Cert-Subject' => "/CN=$host");
    }

    # check compression mode
    if (Compress::Zlib->require()) {
        $self->{compression} = 'native';
        $self->{logger}->debug(
            'Using Compress::Zlib for compression'
        );
    } elsif (system('which gzip >/dev/null 2>&1') == 0) {
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
    my $target   = $self->{target};

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
        $logger->error(
            $res->message()
        );
        return;
    }

    # create response
    my $response_type = ref $message;
    $response_type =~ s/Query/Response/;
    $response_type->require();
    if ($EVAL_ERROR) {
        $logger->error(
            "Can't load response module $response_type: $EVAL_ERROR"
        );
    }

    my $response_content;
    if ($res->content()) {
        $response_content = $self->_uncompress($res->content());
        if (!$response_content) {
            $logger->error("Deflating problem");
            return;
        }
    }

    $logger->debug("receiving message: $response_content");

    my $response = $response_type->new({
        accountinfo => $target->{accountinfo},
        content     => $response_content,
        logger      => $logger,
        origmsg     => $message,
    });

    return $response;
}

# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self, $ca_cert_file, $ca_cert_dir) = @_;

    my $logger = $self->{logger};

    my $hasCrypSSLeay;
    my $hasIOSocketSSL;

    eval {
        require Crypt::SSLeay;
    };
    $hasCrypSSLeay = $EVAL_ERROR ? 0 : 1;

    if (!$hasCrypSSLeay) {
        eval {
            require IO::Socket::SSL;
        };
        $hasIOSocketSSL = $EVAL_ERROR ? 0 : 1;
    }

    if (!$hasCrypSSLeay && !$hasIOSocketSSL) {
        die 
            "Failed to load Crypt::SSLeay or IO::Socket::SSL, to ".
            "validate the server SSL cert. If you want ".
            "to ignore this message and want to ignore SSL ".
            "verification, you can use the ".
            "--no-ssl-check parameter to disable SSL check.";
    }

    if (!$ca_cert_file && !$ca_cert_dir) {
        die
            "You need to use either --ca-cert-file ".
            "or --ca-cert-dir to give the location of your SSL ".
            "certificat. You can also disable SSL check with ".
            "--no-ssl-check but this is very unsecure.";
    }


    if ($ca_cert_file) {
        if (!-f $ca_cert_file && !-l $ca_cert_file) {
            die "--ca-cert-file $ca_cert_file doesn't exist";
        }

        $ENV{HTTPS_CA_FILE} = $ca_cert_file;

        if (!$hasCrypSSLeay && $hasIOSocketSSL) {
            eval {
                IO::Socket::SSL::set_ctx_defaults(
                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                    ca_file => $ca_cert_file
                );
            };
            die
                "Failed to set ca-cert-file: $EVAL_ERROR".
                "Your IO::Socket::SSL distribution is too old. ".
                "Please install Crypt::SSLeay or disable ".
                "SSL server check with --no-ssl-check"
            if $EVAL_ERROR;
        }

    } elsif ($ca_cert_dir) {
        if (!-d $ca_cert_dir) {
            die "--ca-cert-dir $ca_cert_dir doesn't exist";
        }

        $ENV{HTTPS_CA_DIR} = $ca_cert_dir;
        if (!$hasCrypSSLeay && $hasIOSocketSSL) {
            eval {
                IO::Socket::SSL::set_ctx_defaults(
                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                    ca_path => $ca_cert_dir
                );
            };
            die
                "Failed to set ca_cert_dir: $EVAL_ERROR".
                "Your IO::Socket::SSL distribution is too old. ".
                "Please install Crypt::SSLeay or disable ".
                "SSL server check with --no-ssl-check"
            if $EVAL_ERROR;
        }
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

FusionInventory::Agent::Network - the Network abstraction layer

=head1 DESCRIPTION

This module is the abstraction layer for network interaction, based on LWP.
It can validate SSL certificates.

=head1 METHODS

=head2 new

The constructor. The following arguments are allowed:

=over

=item target (mandatory)

=item logger (mandatory)

=item proxy (default: none)

=item realm (default: none)

=item user (default: none)

=item password (default: none)

=item no-ssl-check (default: false)

=back ca-cert-file (default: none)

=back ca-cert-dir (default: none)

=head2 send

Send an instance of C<FusionInventory::Agent::XML::Query> to the target (the
server).
