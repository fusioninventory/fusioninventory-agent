package FusionInventory::Agent::Network;

use strict;
use warnings;

use Carp;
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

    croak 'no target' unless $params->{target};
    croak 'no config' unless $params->{config};

    my $self = {
        config => $params->{config},
        logger => $params->{logger},
        target => $params->{target}
    };
    bless $self, $class;

    # check given URI
    $self->{URI} = URI->new($self->{target}->{path});
    my $scheme = $self->{URI}->scheme();
    if ($scheme ne 'http' && $scheme ne 'https') {
        croak "Invalid protocol for URI: $self->{target}->{path}";
    }
    my $port   = $self->{URI}->port();
    $port =
        $port              ? $port :
        $scheme eq 'https' ? 443   :
                             80    ;
    my $host   = $self->{URI}->host();

    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
    if ($self->{config}->{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $self->{config}->{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }
    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);
    $self->{ua}->credentials(
        "$host:$port",
        $self->{config}->{realm},
        $self->{config}->{user},
        $self->{config}->{password}
    );

    # turns SSL checks on if needed
    if ($scheme eq 'https' && !$self->{config}->{'no-ssl-check'}) {
        $self->turnSSLCheckOn();
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
    $logger->debug ("sending XML");

    my $res = $self->{ua}->request($req);

    # check result
    if (!$res->is_success()) {
        $logger->error(
            "Cannot establish communication with $self->{URI}: " .
            $res->status_line()
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

# No POD documentation here, it's an internal fuction
# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub turnSSLCheckOn {
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
        croak 
            "Failed to load Crypt::SSLeay or IO::Socket::SSL, to ".
            "validate the server SSL cert. If you want ".
            "to ignore this message and want to ignore SSL ".
            "verification, you can use the ".
            "--no-ssl-check parameter to disable SSL check.";
    }
    if (!$config->{'ca-cert-file'} && !$config->{'ca-cert-dir'}) {
        croak
            "You need to use either --ca-cert-file ".
            "or --ca-cert-dir to give the location of your SSL ".
            "certificat. You can also disable SSL check with ".
            "--no-ssl-check but this is very unsecure.";
    }


    my $parameter;
    if ($config->{'ca-cert-file'}) {
        if (!-f $config->{'ca-cert-file'} && !-l $config->{'ca-cert-file'}) {
            croak 
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
            croak
                "Failed to set ca-cert-file: $EVAL_ERROR".
                "Your IO::Socket::SSL distribution is too old. ".
                "Please install Crypt::SSLeay or disable ".
                "SSL server check with --no-ssl-check"
            if $EVAL_ERROR;
        }

    } elsif ($config->{'ca-cert-dir'}) {
        if (!-d $config->{'ca-cert-dir'}) {
            croak "--ca-cert-dir $config->{'ca-cert-dir'} doesn't exist";
        }

        $ENV{HTTPS_CA_DIR} =$config->{'ca-cert-dir'};
        if (!$hasCrypSSLeay && $hasIOSocketSSL) {
            eval {
                IO::Socket::SSL::set_ctx_defaults(
                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                    ca_path => $config->{'ca-cert-dir'}
                );
            };
            croak
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
