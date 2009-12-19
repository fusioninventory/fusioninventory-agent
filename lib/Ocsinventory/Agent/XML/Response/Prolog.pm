package Ocsinventory::Agent::XML::Response::Prolog;

use strict;
use Ocsinventory::Agent::XML::Response;
use Ocsinventory::Agent::XML::Response::Prolog;

our @ISA = ('Ocsinventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);

    bless ($self, $class);
    $self->updatePrologFreq();
    $self->{target}->setNextRunDate();

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

sub updatePrologFreq {
    my $self = shift;
    my $parsedContent = $self->getParsedContent();
     my $logger = $self->{logger};
    if ($parsedContent && exists ($parsedContent->{PROLOG_FREQ})) {
        if( $parsedContent->{PROLOG_FREQ} ne $self->{accountconfig}->get("PROLOG_FREQ")){
             $logger->info("PROLOG_FREQ has changed since last process(old=".$self->{accountconfig}->get("PROLOG_FREQ").",new=".$parsedContent->{PROLOG_FREQ}.")");
             $self->{prologFreqChanged} = 1;
             $self->{accountconfig}->set("PROLOG_FREQ", $parsedContent->{PROLOG_FREQ});
        }
        else{
            $logger->debug("PROLOG_FREQ has not changed since last process");
        }
    }
}

1;
