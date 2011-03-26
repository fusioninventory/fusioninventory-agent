package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use Data::Dumper;
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
        parsedcontent => undef
    };

    bless $self, $class;

    $self->{logger}->debug(
        "=BEGIN=SERVER RET======" .
        Dumper($self->{content}) .
        "=END=SERVER RET======"
    );

    return $self;
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

sub getOptionsInfoByName {
    my ($self, $name) = @_;

    my $parsedContent = $self->getParsedContent();

    return unless $parsedContent && $parsedContent->{OPTION};

    foreach my $option (@{$parsedContent->{OPTION}}) {
        next unless $option->{NAME} eq $name;
        return $option->{PARAM}->[0];
    }

    return;
}

1;
