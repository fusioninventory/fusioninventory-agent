package FusionInventory::Agent::XML::Response::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Response';

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);

    my $target = $self->{target};

    my $parsedContent = $self->getParsedContent();

    $target->setPrologFreq($parsedContent->{PROLOG_FREQ});

    return $self;
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
