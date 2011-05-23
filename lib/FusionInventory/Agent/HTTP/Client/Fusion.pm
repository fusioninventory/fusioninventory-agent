package FusionInventory::Agent::HTTP::Client::Fusion;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use JSON;
use HTTP::Request;

sub send {
    my ($self, %params) = @_;

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});

    $url->query_form(action => $params{action}, %{$params{params}});

    my $request = HTTP::Request->new(GET => $url);

    my $response = $self->request($request);

    return unless $response;

    return eval { from_json( $response, { utf8  => 1 } ) };
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::Fusion - An HTTP client using Fusion protocol

=head1 DESCRIPTION

This is the object used by the agent to send messages to GLPI servers,
using new Fusion protocol (JSON messages sent through GET requests).

=head1 METHODS

=head2 send(%params)

The following parameters are allowed, as keys of the %params
hash:

=over

=item I<url>

the url to send the message to (mandatory)

=item I<action>

the action to perform (mandatory)

=item I<params>

additional params for the action

=back

This method returns a perl data structure.
