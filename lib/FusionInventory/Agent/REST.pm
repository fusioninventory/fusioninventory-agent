package FusionInventory::Agent::REST;

use strict;
use warnings;

use JSON;
use URI::Escape;

our $AUTOLOAD;

sub new {
    my $class = shift;
    my %params = @_; 

    die "missing url key" unless $params{url};
    die "missing network key" unless $params{network};

    my $self = {
        url => $params{url},
        network => $params{network}
    };
    bless $self, $class;
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
    my $jsonText = $self->{network}->get ({
        source => $reqUrl,
        timeout => 60,
        });


    return unless $jsonText;

    return eval { from_json( $jsonText, { utf8  => 1 } ) };
}

sub DESTROY {

}

1;

# my $rest = FusionInventory::Agent::REST->new(
#         "url" => "http://somewhere/",
#         "network" => $network
# );
# my $ret = $rest->getName(param1 => "foo");
# print Dumper($ret);
