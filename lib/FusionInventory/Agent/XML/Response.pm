package FusionInventory::Agent::XML::Response;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = {
        content => $params->{content},
        logger  => $params->{logger},
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
