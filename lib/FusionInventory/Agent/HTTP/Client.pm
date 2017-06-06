package FusionInventory::Agent::HTTP::Client;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Status;
use LWP::UserAgent;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Logger;

my $log_prefix = "[http client] ";

sub new {
    my ($class, %params) = @_;

    die "non-existing certificate file $params{ca_cert_file}"
        if $params{ca_cert_file} && ! -f $params{ca_cert_file};

    die "non-existing certificate directory $params{ca_cert_dir}"
        if $params{ca_cert_dir} && ! -d $params{ca_cert_dir};

    my $self = {
        logger       => $params{logger} ||
                          FusionInventory::Agent::Logger->new(),
        user         => $params{user},
        password     => $params{password},
        ssl_set      => 0,
        no_ssl_check => $params{no_ssl_check},
        no_compress  => $params{no_compress},
        ca_cert_dir  => $params{ca_cert_dir},
        ca_cert_file => $params{ca_cert_file}
    };
    bless $self, $class;

    # create user agent
    $self->{ua} = LWP::UserAgent->new(
        requests_redirectable => ['POST', 'GET', 'HEAD'],
        agent                 => $FusionInventory::Agent::AGENT_STRING,
        timeout               => $params{timeout} || 180,
        parse_head            => 0, # No need to parse HTML
        keep_alive            => 1,
    );

    if ($params{proxy}) {
        $self->{ua}->proxy(['http', 'https'], $params{proxy});
    }  else {
        $self->{ua}->env_proxy();
    }

    return $self;
}

sub request {
    my ($self, $request, $file) = @_;

    my $logger  = $self->{logger};

    my $url = $request->uri();
    my $scheme = $url->scheme();
    $self->_setSSLOptions() if $scheme eq 'https' && !$self->{ssl_set};

    my $result = HTTP::Response->new( 500 );
    eval {
        if ($OSNAME eq 'MSWin32' && $scheme eq 'https') {
            alarm $self->{ua}->timeout();
        }
        $result = $self->{ua}->request($request, $file);
        alarm 0;
    };

    # check result first
    if (!$result->is_success()) {
        # authentication required
        if ($result->code() == 401) {
            if ($self->{user} && $self->{password}) {
                $logger->debug(
                    $log_prefix .
                    "authentication required, submitting credentials"
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
                        alarm $self->{ua}->{timeout};
                    }
                    $result = $self->{ua}->request($request, $file);
                    alarm 0;
                };
                if (!$result->is_success()) {
                    $logger->error(
                        $log_prefix .
                        "authentication required, wrong credentials"
                    );
                }
            } else {
                # abort
                $logger->error(
                    $log_prefix .
                    "authentication required, no credentials available"
                );
            }
        } else {
            $logger->error(
                $log_prefix .
                "communication error: " . $result->status_line()
            );
        }
    }

    return $result;
}

sub _setSSLOptions {
    my ($self) = @_;

    # SSL handling
    if ($self->{no_ssl_check}) {
       # LWP 6 default behaviour is to check hostname
       # Fedora also backported this behaviour change in its LWP5 package, so
       # just checking on LWP version is not enough
       $self->{ua}->ssl_opts(verify_hostname => 0, SSL_verify_mode => 0)
           if $self->{ua}->can('ssl_opts');
    } else {
        # only IO::Socket::SSL can perform full server certificate validation,
        # Net::SSL is only able to check certification authority, and not
        # certificate hostname
        IO::Socket::SSL->require();
        die
            "IO::Socket::SSL Perl module not available, "              .
            "unable to validate SSL certificates "                     .
            "(workaround: use 'no-ssl-check' configuration parameter)"
            if $EVAL_ERROR;

        # Activate SSL Debug if Stderr is in backends
        my $DEBUG_SSL = 0;
        $DEBUG_SSL = grep { ref($_) =~/Stderr$/ } @{$self->{logger}{backends}}
            if (ref($self->{logger}{backends}) eq 'ARRAY');
        if ( $DEBUG_SSL && $self->{logger}{verbosity} >= LOG_DEBUG2 ) {
            $Net::SSLeay::trace = 3;
        }

        if ($LWP::VERSION >= 6) {
            $self->{ua}->ssl_opts(SSL_ca_file => $self->{ca_cert_file})
                if $self->{ca_cert_file};
            $self->{ua}->ssl_opts(SSL_ca_path => $self->{ca_cert_dir})
                if $self->{ca_cert_dir};
        } else {
            # SSL_verifycn_scheme and SSL_verifycn_name are required
            die
                "IO::Socket::SSL Perl module too old "                     .
                "(available: $IO::Socket::SSL::VERSION, required: 1.14), " .
                "unable to validate SSL certificates "                     .
                "(workaround: use 'no-ssl-check' configuration parameter)"
                if $IO::Socket::SSL::VERSION < 1.14;

            # use a custom HTTPS handler to workaround default LWP5 behaviour
            FusionInventory::Agent::HTTP::Protocol::https->use(
                ca_cert_file => $self->{ca_cert_file},
                ca_cert_dir  => $self->{ca_cert_dir},
            );

            LWP::Protocol::implementor(
                'https', 'FusionInventory::Agent::HTTP::Protocol::https'
            );

            # abuse user agent internal to pass values to the handler, so
            # as to have different behaviors in the same process
            $self->{ua}->{ssl_check} = $self->{no_ssl_check} ? 0 : 1;
        }
    }

    $self->{ssl_set} = 1;
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
