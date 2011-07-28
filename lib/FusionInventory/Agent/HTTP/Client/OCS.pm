package FusionInventory::Agent::HTTP::Client::OCS;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use English qw(-no_match_vars);
use HTTP::Request;
use UNIVERSAL::require;
use URI;

use FusionInventory::Agent::XML::Response;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{ua}->default_header('Pragma' => 'no-cache');

    # check compression mode
    if (Compress::Zlib->require()) {
        $self->{compression} = 'native';
        $self->{ua}->default_header('Content-type' => 'application/x-compress');
        $self->{logger}->debug(
            'Using Compress::Zlib for compression'
        );
    } elsif (canRun('gzip')) {
        $self->{compression} = 'gzip';
        $self->{ua}->default_header('Content-type' => 'application/x-compress');
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

    my $request_content = $message->getContent();
    $logger->debug2("[client] sending message:\n $request_content");

    $request_content = $self->_compress($request_content);
    if (!$request_content) {
        $logger->error('[client] inflating problem');
        return;
    }

    my $request = HTTP::Request->new(POST => $url);
    $request->content($request_content);

    my $response = $self->request($request);
    return unless $response->is_success();

    my $response_content = $response->content();

   if (!$response_content) {
        $logger->error("[client] response is empty");
        return;
    }

    my $uncompressed_response_content = $self->_uncompress($response_content);
    if ($uncompressed_response_content) {
        $response_content = $uncompressed_response_content;
    } else {
        $logger->info(
            "[client] deflating failure: this is not compressed content"
        );
    }

    $logger->debug2("[client] receiving message:\n $response_content");

    return FusionInventory::Agent::XML::Response->new(
        content => $response_content
    );
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

The following parameters are allowed, as keys of the %params
hash:

=over

=item I<url>

the url to send the message to (mandatory)

=item I<message>

the message to send (mandatory)

=back

This method returns an C<FusionInventory::Agent::XML::Response> instance.
