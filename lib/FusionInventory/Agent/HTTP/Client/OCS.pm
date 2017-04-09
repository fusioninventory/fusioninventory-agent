package FusionInventory::Agent::HTTP::Client::OCS;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use English qw(-no_match_vars);
use HTTP::Request;
use UNIVERSAL::require;
use URI;
use Encode;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Response;

my $log_prefix = "[http client] ";

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{ua}->default_header('Pragma' => 'no-cache');

    $self->{ua}->default_header('Content-type' => 'application/xml');

    return $self;
}

sub send { ## no critic (ProhibitBuiltinHomonyms)
    my ($self, %params) = @_;

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});
    my $message = $params{message};
    my $logger  = $self->{logger};

    my $request_content = $message->getContent();
    $logger->debug2($log_prefix . "sending message:\n $request_content");

    $request_content = encode('UTF-8', $request_content);
    if (!$request_content) {
        $logger->error($log_prefix . 'inflating problem');
        return;
    }

    my $request = HTTP::Request->new(POST => $url);
    $request->content($request_content);

    my $response = $self->request($request);

    # no need to log anything specific here, it has already been done
    # in parent class
    return if !$response->is_success();

    my $response_content = $response->content();
    if (!$response_content) {
        $logger->error($log_prefix . "unknown content format");
        return;
    }

    $logger->debug2($log_prefix . "receiving message:\n $response_content");

    my $result;
    eval {
        $result = FusionInventory::Agent::XML::Response->new(
            content => $response_content
        );
    };
    if ($EVAL_ERROR) {
        my @lines = split(/\n/, $response_content);
        $logger->error(
            $log_prefix . "unexpected content, starting with $lines[0]"
        );
        return;
    }

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
