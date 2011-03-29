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

    my $self = {
        logger         => $params->{logger},
        user           => $params->{user},
        password       => $params->{password},
        realm          => $params->{realm},
        proxy          => $params->{proxy},
        ca_cert_file   => $params->{ca_cert_file},
        ca_cert_dir    => $params->{ca_cert_dir},
        no_ssl_check   => $params->{no_ssl_check},
        url            => $params->{url},
        defaultTimeout => 180
    };
    bless $self, $class;

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

sub createUA {
    my ($self, $args) = @_;

    my $noProxy = $args->{noProxy};
    my $timeout = $args->{timeout};
    my $forceRealm = $args->{forceRealm};

    my $logger = $self->{logger};
    
    my $url      = URI->new($args->{url});
    my $host     = $url->host();
    my $protocol = $url->scheme();
    my $port     = $url->port();

   if (!$port) {
       $port = $protocol eq 'https' ? 443 : 80;
   }

    die "Unsupported protocol $protocol"
        unless $protocol eq 'http' or $protocol eq 'https';

    my $ua = LWP::UserAgent->new(keep_alive => 1);

    if ($noProxy) {

        # Not thread safe :(
        foreach (qw/HTTP_PROXY HTTPS_PROXY/) {
            next unless $ENV{$_};
            $self->{ProxySaved}{$_} = $ENV{$_};
            $ENV{$_} = undef;
        }

    } else {

        foreach (qw/HTTP_PROXY HTTPS_PROXY/) {
            next unless $self->{ProxySaved}{$_};
            $ENV{$_} = $self->{ProxySaved}{$_};
            undef $self->{ProxySaved}{$_};
        }

    }


    if ($self->{proxy}) {

        if ($protocol eq 'http') {
            $ENV{HTTP_PROXY} = $self->{proxy};
            $ua->env_proxy;
        } elsif ($protocol eq 'https') {
            $ENV{HTTPS_PROXY} = $self->{proxy};
            # Crypt::SSLeay do the proxy connexion itself with
            # $ENV{HTTPS_PROXY}.
        }

    }

    # Connect to server
    $ua->agent($FusionInventory::Agent::AGENT_STRING);
    $ua->timeout($timeout);

    my $scheme = $url->scheme();
    if ($scheme eq 'https' && !$self->{no_ssl_check}) {
        $self->_turnSSLCheckOn();
        $self->_setSslRemoteHost({
            ua => $ua,
            url => $url
        });
    }

    # Auth
    my $realm = $forceRealm || $self->{realm};
    $ua->credentials(
        "$host:$port",
        $realm,
        $self->{user},
        $self->{password}
    );

    return $ua;
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

    my $ua = $self->createUA({url => $self->{url}});
    my $res;
    eval {
        if ($^O =~ /^MSWin/ && $self->{url} =~ /^https:/g) {
            alarm $self->{defaultTimeout};
        }
        $res = $ua->request($req);
        alarm 0;
    };


    my $serverRealm;
    if ($res->code == '401' && $res->header('www-authenticate') =~ /^Basic realm="(.*)"/ && !$self->{realm}) {
        $serverRealm = $1;
        $logger->debug("Basic HTTP Auth: fixing the realm to '$serverRealm' and retrying.");

        $ua = $self->createUA({url => $self->{url}, forceRealm => $serverRealm});
        eval {
            if ($^O =~ /^MSWin/ && $self->{url} =~ /^https:/g) {
                alarm $self->{defaultTimeout};
            }
            $res = $ua->request($req);
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

    my $logger = $self->{logger};

    eval {
        require Crypt::SSLeay;
    };
    if ($EVAL_ERROR) {
        die 
            "failed to load Crypt::SSLeay, unable to validate SSL certificates";
    }

    if (!$self->{ca_cert_file} && !$self->{ca_cert_dir}) {
        $logger->debug("You may need to use either --ca-cert-file ".
            "or --ca-cert-dir to give the location of your SSL ".
            "certificat. You can also disable SSL check with ".
            "--no-ssl-check but this is very unsecure.");
    }


    if ($self->{ca_cert_file}) {
        if (!-f $self->{ca_cert_file} && !-l $self->{ca_cert_file}) {
            die "--ca-cert-file doesn't exist `".$self->{ca_cert_file}."'";
        }

        $ENV{HTTPS_CA_FILE} = $self->{ca_cert_file};

    } elsif ($self->{ca_cert_dir}) {
        if (!-d $self->{ca_cert_dir}) {
            die "--ca-cert-dir doesn't exist `".$self->{ca_cert_dir}."'";
        }

        $ENV{HTTPS_CA_DIR} =$self->{ca_cert_dir};

    }

}

sub _setSslRemoteHost {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    my $url = $args->{url};
    my $ua = $args->{ua};

    # Check server name against provided SSL certificate
    if ( $self->{url} =~ /^https:\/\/([^\/]+).*$/i ) {
        my $re = $1;
        # Accept SSL cert will hostname with wild-card
        # http://forge.fusioninventory.org/issues/542
        $re =~ s/^([^\.]+)/($1|\\*)/;
        # protect some characters, $re will be evaluated as a regex
        $re =~ s/([\-\.])/\\$1/g;
        $ua->default_header('If-SSL-Cert-Subject' => '/CN='.$re.'($|\/)');
    }
}


sub getStore {
    my ($self, $args) = @_;

    my $source = $args->{source};
    my $timeout = $args->{timeout};
    my $noProxy = $args->{noProxy};

    my $ua = $self->createUA({
            url     => $source,
            timeout => $timeout,
            noProxy => $noProxy,
        });

    $ua->timeout($timeout) if $timeout;

    my $response;
    eval {
        if ($^O =~ /^MSWin/ && $source =~ /^https:/g) {
            alarm $self->{defaultTimeout};
        }

        my $request = HTTP::Request->new(GET => $source);
        $response = $ua->request($request);
        alarm 0;
    };

    return $response->code;

}

sub get {
    my ($self, $args) = @_;

    my $source = $args->{source};
    my $timeout = $args->{timeout};
    my $noProxy = $args->{noProxy};

    my $ua = $self->createUA({
            url     => $source,
            timeout => $timeout,
            noProxy => $noProxy,
        });

    my $response = $ua->get($source);

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
