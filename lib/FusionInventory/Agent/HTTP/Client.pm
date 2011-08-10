package FusionInventory::Agent::HTTP::Client;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    die "non-existing certificate file $params{ca_cert_file}"
        if $params{ca_cert_file} && ! -f $params{ca_cert_file};

    die "non-existing certificate directory $params{ca_cert_dir}"
        if $params{ca_cert_dir} && ! -d $params{ca_cert_dir};

    my $self = {
        logger           => $params{logger} ||
                           FusionInventory::Agent::Logger->new(),
        user             => $params{user},
        password         => $params{password},
        timeout          => $params{timeout} || 180,

        no_ssl_check     => $params{'no_ssl_check'},
        ssl_socket_class => $params{ssl_socket_class} || "IO::Socket::SSL",

        ca_cert_file     => $params{ca_cert_file},
        ca_cert_dir      => $params{ca_cert_dir},
    };
    bless $self, $class;

#    $Net::HTTPS::SSL_SOCKET_CLASS = $self->{ssl_socket_class};
    # create user agent
    $self->{ua} = LWP::UserAgent->new(keep_alive => 1, requests_redirectable => ['POST', 'GET', 'HEAD']);

    if ($params{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $params{proxy});
    }  else {
        $self->{ua}->env_proxy;
    }


    $self->{ua}->agent($FusionInventory::Agent::AGENT_STRING);
    $self->{ua}->timeout($params{timeout});

    return $self;
}

sub _turnSSLOn {
    my ($self) = @_;

    # Already loaded?
    return if $self->{ssl_on};

    $ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS}=$self->{ssl_socket_class};
    # SSL handling
    if ($self->{'no_ssl_check'}) {
        if ($LWP::VERSION >= 6) {
            # LWP6 default behavior is to check the SSL hostname
            $self->{ua}->ssl_opts(verify_hostname => 0);
        }
    } elsif ($self->{ssl_socket_class} ne 'Net::SSL' && IO::Socket::SSL->require() && !$EVAL_ERROR) {
        $self->{ssl_socket_class} = "IO::Socket::SSL";

        if ($LWP::VERSION >= 6) {
            $self->{ua}->ssl_opts(SSL_ca_file => $self->{'ca_cert_file'})
                if $self->{'ca_cert_file'};
            $self->{ua}->ssl_opts(SSL_ca_path => $self->{'ca_cert_dir'})
                if $self->{'ca_cert_dir'};
        } else {
            # use a custom HTTPS handler to workaround default LWP5 behaviour
            FusionInventory::Agent::HTTP::Protocol::https->use(
                ca_cert_file => $self->{'ca_cert_file'},
                ca_cert_dir  => $self->{'ca_cert_dir'},
            );
            die 
                "failed to load FusionInventory::Agent::HTTP::Protocol::https" .
                ", unable to perform SSL certificate validation"
                if $EVAL_ERROR;

            LWP::Protocol::implementor(
                'https', 'FusionInventory::Agent::HTTP::Protocol::https'
            );

            # abuse user agent internal to pass values to the handler, so
            # as to have different behaviors in the same process
            $self->{ua}->{ssl_check} = $self->{'no_ssl_check'} ? 0 : 1;
        }
    } elsif (Crypt::SSLeay->require() && !$EVAL_ERROR) {
        # This option has some limitation what's why IO::Socket::SSL
        # remains the best option:
        #  - No alternate hostname support
        #  - Hostname validation has to be done manually
        $self->{ssl_socket_class} = "Net::SSL";
        if ($LWP::VERSION >= 6) {
            $self->{ua}->ssl_opts(SSL_ca_file => $self->{'ca_cert_file'})
	        if $self->{'ca_cert_file'};
            $self->{ua}->ssl_opts(SSL_ca_path => $self->{'ca_cert_dir'})
                if $self->{'ca_cert_dir'};
            # Net::SSL+Crypt::SSLeay are not able to turn OpenSSL internal
            # hostname check. We check that ourself with If-SSL-Cert-Subject
            # after. For the moment we turn verify_hostname off
            $self->{ua}->ssl_opts(verify_hostname => 0);
            $self->{ua}->ssl_opts(SSL_verify_mode => 1);
#            $self->{ua}->ssl_opts(SSL_verifycn_scheme => 'www');

	}
        $ENV{HTTPS_CA_FILE} = $self->{'ca_cert_file'}
            if $self->{'ca_cert_file'};
        $ENV{HTTPS_CA_DIR} = $self->{'ca_cert_dir'}
            if $self->{'ca_cert_dir'};


        # abuse user agent internal to pass values to the handler, so
        # as to have different behaviors in the same process
        $self->{ua}->{ssl_check} = $self->{'no_ssl_check'} ? 0 : 1;


    } else {
        die
            "failed to load IO::Socket::SSL or Crypt::SSLeay" .
            ", unable to perform SSL certificate validation"
    }

    $self->{logger}->debug("SSL: ".$self->{ssl_socket_class}." loaded");

    $self->{ssl_on} = 1;

}

sub request {
    my ($self, $request) = @_;

    my $logger  = $self->{logger};

    # activate SSL if needed
    my $url = $request->uri();
    my $scheme = $url->scheme();

    if ($scheme eq 'https') {
        $self->_turnSSLOn();
# Restore the initial socket class. Needed by the test-suite
#        $Net::HTTPS::SSL_SOCKET_CLASS = $self->{ssl_socket_class};
        $ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS}=$self->{ssl_socket_class};
        $self->{ua}->default_header('');
#        $self->{ua}->ssl_opts(SSL_verifycn_scheme => undef);
        if ( (!$self->{no_ssl_check}) && $self->{ssl_socket_class} eq 'Net::SSL' && $url =~ /^https:\/\/([^\/]+).*$/i ) {
            my $re = $1;
# Accept SSL cert will hostname with wild-card
# http://forge.fusioninventory.org/issues/542
            $re =~ s/^([^\.]+)/($1|\\*)/;
# protect some characters, $re will be evaluated as a regex
            $re =~ s/([\-\.])/\\$1/g;
# Drop the port numbers
            $re =~ s/:\d+//g;
            $self->{ua}->default_header('If-SSL-Cert-Subject' => '/CN='.$re.'($|\/)');
        }
    }

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
                }
            } else {
                # abort
                $logger->error(
                    "[client] authentication required, no credentials " .
                    "available"
                );
            }
        } else {
            $logger->error(
                "[client] cannot establish communication with $url: " .
                $result->status_line()
            );
        }
    }

    return $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client - An abstract HTTP client

=head1 DESCRIPTION

This is an abstract class for HTTP clients. It can send messages through HTTP
or HTTPS, directly or through a proxy, and validate SSL certificates.

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

=head2 request($request)

Send given HTTP::Request object, handling SSL checking and user authentication
automatically if needed.
