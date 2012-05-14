package FusionInventory::Agent::HTTP::Client::Fusion;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use JSON;
use HTTP::Request;
use URI::Escape;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

# Stack the messages sent in order to be able to check the
# correctness of the behavior with the test-suite
    if ($params{debug}) {
        $self->{debug} = 1;
        $self->{msgStack} = []
    }

    return $self;
}

sub _prepareVal {
    my ($self, $val) = @_;

    return '' unless length($val);

# forbid to long argument.
    while (length(URI::Escape::uri_escape_utf8($val)) > 1500) {
        $val =~ s/^.{5}/…/;
    }

    return URI::Escape::uri_escape_utf8($val);
}

sub send { ## no critic (ProhibitBuiltinHomonyms)
    my ($self, %params) = @_;

    push @{$self->{msgStack}}, $params{args} if $self->{debug};

    my $url = ref $params{url} eq 'URI' ?
        $params{url} : URI->new($params{url});

    my $finalUrl = $url.'?action='.uri_escape($params{args}->{action});
    foreach my $k (keys %{$params{args}}) {
        if (ref($params{args}->{$k}) eq 'ARRAY') {
            foreach (@{$params{args}->{$k}}) {
                $finalUrl .= '&'.$k.'[]='.$self->_prepareVal($_ || '');
            }
        } elsif (ref($params{args}->{$k}) eq 'HASH') {
            foreach (keys %{$params{args}->{$k}}) {
                $finalUrl .= '&'.$k.'['.$_.']='.$self->_prepareVal($params{args}->{$k}{$_});
            }
        } elsif ($k ne 'action' && length($params{args}->{$k})) {
            $finalUrl .= '&'.$k.'='.$self->_prepareVal($params{args}->{$k});
        }
   }

    $self->{logger}->debug2($finalUrl) if $self->{logger};

    my $request = HTTP::Request->new(GET => $finalUrl);

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
