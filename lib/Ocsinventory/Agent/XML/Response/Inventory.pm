package Ocsinventory::Agent::XML::Response::Inventory;

use strict;
use Ocsinventory::Agent::XML::Response;
our @ISA = ('Ocsinventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $this = $class->SUPER::new(@params);
    bless ($this, $class);

    my $parsedContent = $this->getParsedContent();
    if ($parsedContent && exists ($parsedContent->{RESPONSE}) && $parsedContent->{RESPONSE} =~ /^ACCOUNT_UPDATE$/) {
      $this->updateAccountInfo();
    }
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

sub updateAccountInfo {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();

    $self->{accountinfo}->reSetAll($parsedContent->{ACCOUNTINFO});
}
1;
