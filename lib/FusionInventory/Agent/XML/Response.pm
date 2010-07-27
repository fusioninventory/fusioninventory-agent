package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = {
        content       => $params->{content},
        logger        => $params->{logger},
        target        => $params->{target},
    };
    bless $self, $class;

    return $self;
}

sub getContent {
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
