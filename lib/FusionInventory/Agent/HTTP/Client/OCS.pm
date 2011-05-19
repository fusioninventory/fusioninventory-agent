package FusionInventory::Agent::HTTP::Client::OCS;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use English qw(-no_match_vars);
use HTTP::Status;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::XML::Response;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

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
    if ($scheme eq 'https' && $LWP::VERSION < 6 && !$self->{no_ssl_check}) {
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

FusionInventory::Agent::HTTP::Client::OCS - An HTTP client using OCS protocol

=head1 DESCRIPTION

This is the object used by the agent to send messages to OCS or GLPI servers,
using original OCS protocol (XML messages sent through POST requests).

=head1 METHODS

=head2 send(%params)

Send an instance of C<FusionInventory::Agent::XML::Query> to the target (the
server).
