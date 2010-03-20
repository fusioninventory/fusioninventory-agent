package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use Data::Dumper;

use XML::Simple;
sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{accountconfig} = $params->{accountconfig};
    $self->{accountinfo} = $params->{accountinfo};
    $self->{content}  = $params->{content};
    $self->{config} = $params->{config};
    my $logger = $self->{logger}  = $params->{logger};
    $self->{origmsg}  = $params->{origmsg};
    $self->{target}  = $params->{target};

    $logger->debug("=BEGIN=SERVER RET======");
    $logger->debug(Dumper($self->{content}));
    $logger->debug("=END=SERVER RET======");

    $self->{parsedcontent}  = undef;

    bless $self;
}

sub getRawXML {
    my $self = shift;

    return $self->{content};

}

sub getParsedContent {
    my $self = shift;

    if(!$self->{parsedcontent} && $self->{content}) {
        $self->{parsedcontent} = XML::Simple::XMLin( $self->{content}, ForceArray => ['OPTION','PARAM'] );
    }

    return $self->{parsedcontent};
}

sub origMsgType {
    my ($self, $package) = @_;

    return ref($package);
}

1;
