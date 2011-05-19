package FusionInventory::Agent::HTTP::Client::Fusion;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use JSON;
use URI::Escape;

our $AUTOLOAD;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{url} = $params{url};
    return $self;
}

sub AUTOLOAD {
    my $self = shift;
    my %params = @_;

    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion


    my $reqUrl = $self->{url}.'?action='.$name;
    foreach my $k (keys %params) {
        if (ref($params{$k}) eq 'ARRAY') {
            foreach (@{$params{$k}}) {
                $reqUrl .= '&'.$k.'[]='.uri_escape($_ || '');
            }
        } elsif (ref($params{$k}) eq 'HASH') {
            foreach (keys %{$params{$k}}) {
                $reqUrl .= '&'.$k.'['.$_.']='.uri_escape($params{$k}->{$_} || '');
            }

        } else {
            $reqUrl .= '&'.$k.'='.uri_escape($params{$k} || '');
        }
    }

    my $jsonText = $self->{ua}->get ({
        source => $reqUrl,
        timeout => 60,
        });


    return unless $jsonText;

    return eval { from_json( $jsonText, { utf8  => 1 } ) };
}

sub DESTROY {

}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::Fusion - An HTTP client using Fusion protocol

=head1 DESCRIPTION

This is the object used by the agent to send messages to GLPI servers,
using new Fusion protocol (JSON messages sent through GET requests).

=head1 METHODS

# my $rest = FusionInventory::Agent::REST->new(
#         "url" => "http://somewhere/",
#         "network" => $network
# );
# my $ret = $rest->getName(param1 => "foo");
# print Dumper($ret);
