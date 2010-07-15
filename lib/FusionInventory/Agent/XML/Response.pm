package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::TreePP;

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

sub getContent {
    my $self = shift;

    return $self->{content};

}

sub getParsedContent {
    my $self = shift;

    if(!$self->{parsedcontent} && $self->{content}) {
        my $tpp =  XML::TreePP->new( force_array => [ 'OPTION','PARAM' ],
            text_node_key => 'content',
            attr_prefix => '' );
        my $tmp = $tpp->parse( $self->{content} );
        return unless $tmp->{REPLY};
        $self->{parsedcontent} = $tmp->{REPLY};
    }

    return $self->{parsedcontent};
}

1;
