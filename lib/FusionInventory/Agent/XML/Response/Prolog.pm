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

1;
