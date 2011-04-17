package FusionInventory::Agent::REST;

use strict;
use warnings;

use FusionInventory::Agent::Network;
use JSON;

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

    my $reqUrl = $self->{url}.'?a='.$name;
    foreach my $k (keys %params) {
        $reqUrl .= '&'.$k.'='.$params{$k};
    }

    my $jsonText = $self->{network}->get ({
        source => $reqUrl,
        timeout => 60,
        });


    return unless $jsonText;

    return from_json( $jsonText, { utf8  => 1 } );
}

1;

# my $rest = FusionInventory::Agent::REST->new(
#         "url" => "http://somewhere/",
#         "network" => $network
# );
# my $ret = $rest->getName(param1 => "foo");
# print Dumper($ret);
