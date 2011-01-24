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
use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    die "non-existing certificate file $params{ca_cert_file}"
        if $params{ca_cert_file} && ! -f $params{ca_cert_file};

    die "non-existing certificate directory $params{ca_cert_dir}"
        if $params{ca_cert_dir} && ! -d $params{ca_cert_dir};

    my $self = {
        logger       => $params{logger} || FusionInventory::Agent::Logger->new(),
        user         => $params{user},
        password     => $params{password},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
        defaultTimeout => 180,
    };
    bless $self, $class;

    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1);

    if ($params{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $params{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }

    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);


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

    my $logger = $self->{logger};

    my $message = $params{message};
    my $url     = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});

    # turns SSL checks on if needed
    my $scheme = $url->scheme();
    if ($scheme eq 'https' && !$self->{no_ssl_check}) {
        $self->_turnSSLCheckOn();
        my $re = $url->host();

	# Accept SSL cert will hostname with wild-card
	# http://forge.fusioninventory.org/issues/542
        $re =~ s/^([^\.]+)/($1|\\*)/;
	# protect metacharacters, as $re will be evaluated as a regex
        $re =~ s/\./\\./g;
        $self->{ua}->default_header('If-SSL-Cert-Subject' => "/CN=$re($|\/)");
    }

    my $message_content = $self->_compress($message->getContent());
    if (!$message_content) {
        $logger->error('Inflating problem');
        return;
    }

    my $req = HTTP::Request->new(POST => $url);

    $req->header(
        'Pragma'       => 'no-cache',
        'Content-type' => 'application/x-compress'
    );

    $req->content($message_content);

    # send it
    $logger->debug("sending message");

    my $res;
    eval {
        if ($OSNAME eq 'MSWin32' && $scheme eq 'https') {
            alarm $self->{defaultTimeout};
        }
        $res = $self->{ua}->request($req);
        alarm 0;
    };

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
                        alarm $self->{defaultTimeout};
                    }
                    $res = $self->{ua}->request($req);
                    alarm 0;
                };
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

    my $response = FusionInventory::Agent::XML::Response->new(
        content => $response_content,
        logger  => $logger,
    );

    return $response;
}

# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub _turnSSLCheckOn {
    my ($self) = @_;

    my $logger = $self->{logger};

    eval {
        require Crypt::SSLeay;
    };
    if ($EVAL_ERROR) {
        die 
            "failed to load Crypt::SSLeay, unable to validate SSL certificates";
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

    my $handle = getFileHandle(
        command => 'gzip -c ' . $in->filename(),
    );
    return unless $handle;

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $result = <$handle>;
    close $handle;

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

=head2 send

Send an instance of C<FusionInventory::Agent::XML::Query> to the target (the
server).
