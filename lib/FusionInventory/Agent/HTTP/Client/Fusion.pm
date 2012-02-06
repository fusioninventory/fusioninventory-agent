package FusionInventory::Agent::HTTP::Client::Fusion;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use JSON;
use HTTP::Request;
use URI::Escape;

sub _prepareVal {
    my ($self, $val) = @_;

    return '' unless length($val);

    # forbid too long argument.
    while (length(uri_escape($val)) > 1500) {
        $val =~ s/^.{5}/…/;
    }

    return uri_escape($val);
}

sub send {
    my ($self, %params) = @_;

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});

    $url .= '?action=' . uri_escape($params{args}->{action});

    foreach my $arg (keys %{$params{args}}) {
        my $value = $params{args}->{$arg};
        if (ref $value eq 'ARRAY') {
            foreach (@$value) {
                $url .= '&' . $arg . '[]=' .$self->_prepareVal($_ || '');
            }
        } elsif (ref $value eq 'HASH') {
            foreach (keys %$value) {
                $url .= '&' . $arg . '[' . $_. ']=' . $self->_prepareVal($value->{$_});
            }
        } elsif ($arg ne 'action' && length($value)) {
            $url .= '&' . $arg . '=' . $self->_prepareVal($value);
        }
    }

    $self->{logger}->debug2($url) if $self->{logger};

    my $request = HTTP::Request->new();

    $request->uri($url);
    if ($params{postData}) {
        $request->content($params{postData});
        $request->method('POST');
    } else {
        $request->method('GET');
    }

    my $response = $self->request($request);

    return unless $response;

    return eval { from_json( $response->content(), { utf8  => 1 } ) };
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

=item I<args>

A list of parameters to pass to the server. The action key is mandatory.
Parameters can be hashref or arrayref.

=back

This method returns a perl data structure.
