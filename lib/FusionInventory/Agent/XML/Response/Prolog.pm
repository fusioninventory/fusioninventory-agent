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

sub isInventoryAsked {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();

    if (
        $parsedContent &&
        exists $parsedContent->{RESPONSE} &&
        $parsedContent->{RESPONSE} eq 'SEND'
    ) {
        return 1;
    } else {
        return 0;
    }
}

1;
