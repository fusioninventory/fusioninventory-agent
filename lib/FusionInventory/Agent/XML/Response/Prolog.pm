package FusionInventory::Agent::XML::Response::Prolog;

use strict;
use FusionInventory::Agent::XML::Response;

our @ISA = ('FusionInventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);

    bless ($self, $class);

    my $target = $self->{target};

    my $parsedContent = $self->getParsedContent();

    $target->setPrologFreq($parsedContent->{PROLOG_FREQ});

    return $self;
}

sub isInventoryAsked {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();
    if ($parsedContent && exists ($parsedContent->{RESPONSE}) && $parsedContent->{RESPONSE} =~ /^SEND$/) {
	return 1;
    }

    0
}

sub getOptionsInfoByName {
    my ($self, $name) = @_;

    my $parsedContent = $self->getParsedContent();

    my $ret = [];
    return unless ($parsedContent && $parsedContent->{OPTION});
    foreach (@{$parsedContent->{OPTION}}) {
      if ($_->{NAME} && $_->{NAME} =~ /^$name$/i) {
        $ret = $_->{PARAM}
      }
    }

    return $ret;
}


1;
