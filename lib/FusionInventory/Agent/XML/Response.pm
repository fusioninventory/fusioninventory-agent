package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = {
        accountconfig => $params->{accountconfig},
        accountinfo   => $params->{accountinfo},
        content       => $params->{content},
        config        => $params->{config},
        logger        => $params->{logger},
        origmsg       => $params->{origmsg},
        target        => $params->{target},
        parsedcontent => undef
    };
    bless $self, $class;

    return $self;
}

sub getRawXML {
    my $self = shift;

    return $self->{content};

}

sub getParsedContent {
    my $self = shift;

    if(!$self->{parsedcontent} && $self->{content}) {
        $self->{parsedcontent} = XMLin(
            $self->{content},
            ForceArray => ['OPTION','PARAM']
        );
    }

    return $self->{parsedcontent};
}

1;
