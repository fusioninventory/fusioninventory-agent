package FusionInventory::Agent::Network;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;
use URI;

use FusionInventory::Compress;

=over 4

=item new()

The constructor. These keys are expected: config, logger, target.

=cut

sub new {
    my ($class, $params) = @_;

    die 'no target' unless $params->{target};
    die 'no config' unless $params->{config};

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
        config => $params->{config},
        logger => $params->{logger},
        target => $params->{target},
        URI    => $uri
    };
    bless $self, $class;

    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1);

  if ($self->{config}->{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $self->{config}->{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }
    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);

    if (
        $self->{config}->{realm} ||
        $self->{config}->{user}  ||
        $self->{config}->{password}
    ) {
        $self->{ua}->credentials(
            "$host:$port",
            $self->{config}->{realm},
            $self->{config}->{user},
            $self->{config}->{password}
        );
    }

    # turns SSL checks on if needed
    if ($scheme eq 'https' && !$self->{config}->{'no-ssl-check'}) {
        $self->_turnSSLCheckOn();
        $self->{ua}->default_header('If-SSL-Cert-Subject' => "/CN=$host");
    }

    $self->{compress} = FusionInventory::Compress->new({
        logger => $self->{logger}
    });

    return $self;
}

=item send()

Send an instance of FusionInventory::Agent::XML::Query::* to the target (the
server).

=cut

sub send {
    my ($self, $args) = @_;

    my $logger   = $self->{logger};
    my $target   = $self->{target};
    my $config   = $self->{config};
    my $compress = $self->{compress};

    # create message
    my $message = $args->{message};
    my $message_content = $compress->compress($message->getContent());
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
        $response_content = $compress->uncompress($res->content());
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
        target      => $target,
        config      => $self->{config}
    });

    return $response;
}

# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self, $args) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

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

    if (!$config->{'ca-cert-file'} && !$config->{'ca-cert-dir'}) {
        die
            "You need to use either --ca-cert-file ".
            "or --ca-cert-dir to give the location of your SSL ".
            "certificat. You can also disable SSL check with ".
            "--no-ssl-check but this is very unsecure.";
    }


    if ($config->{'ca-cert-file'}) {
        if (!-f $config->{'ca-cert-file'} && !-l $config->{'ca-cert-file'}) {
            die 
                "--ca-cert-file $config->{'ca-cert-file'} doesn't exist";
        }

        $ENV{HTTPS_CA_FILE} = $config->{'ca-cert-file'};

        if (!$hasCrypSSLeay && $hasIOSocketSSL) {
            eval {
                IO::Socket::SSL::set_ctx_defaults(
                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                    ca_file => $config->{'ca-cert-file'}
                );
            };
            die
                "Failed to set ca-cert-file: $EVAL_ERROR".
                "Your IO::Socket::SSL distribution is too old. ".
                "Please install Crypt::SSLeay or disable ".
                "SSL server check with --no-ssl-check"
            if $EVAL_ERROR;
        }

    } elsif ($config->{'ca-cert-dir'}) {
        if (!-d $config->{'ca-cert-dir'}) {
            die "--ca-cert-dir $config->{'ca-cert-dir'} doesn't exist";
        }

        $ENV{HTTPS_CA_DIR} =$config->{'ca-cert-dir'};
        if (!$hasCrypSSLeay && $hasIOSocketSSL) {
            eval {
                IO::Socket::SSL::set_ctx_defaults(
                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                    ca_path => $config->{'ca-cert-dir'}
                );
            };
            die
                "Failed to set ca-cert-file: $EVAL_ERROR".
                "Your IO::Socket::SSL distribution is too old. ".
                "Please install Crypt::SSLeay or disable ".
                "SSL server check with --no-ssl-check"
            if $EVAL_ERROR;
        }
    }

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Network - the Network abstraction layer

=head1 DESCRIPTION

This module is the abstraction layer for network interaction. It uses LWP.
Not like LWP, it can vlaide SSL certificat with Net::SSLGlue::LWP.
