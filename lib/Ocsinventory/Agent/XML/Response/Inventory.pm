package Ocsinventory::Agent::XML::Response::Inventory;

use strict;
use Ocsinventory::Agent::XML::Response;
our @ISA = ('Ocsinventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $this = $class->SUPER::new(@params);
    bless ($this, $class);

    $this->updatePrologFreq();
    $this->updateAccountInfo();

    return $this;
}

sub isAccountUpdated {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();
    if ($parsedContent && exists ($parsedContent->{RESPONSE}) && $parsedContent->{RESPONSE} =~ /^ACCOUNT_UPDATE$/) {
	return 1;
    }

    0

}

sub updatePrologFreq {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();
    if ($parsedContent && exists ($parsedContent->{PROLOG_FREQ})) {
	$self->{accountconfig}->set("PROLOG_FREQ", $parsedContent->{PROLOG_FREQ});
    }
}

sub updateAccountInfo {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();
    if ($parsedContent && exists ($parsedContent->{ACCOUNTINFO})) {
	$self->{accountinfo}->reSetAll($parsedContent->{ACCOUNTINFO});
    }
}
1;
