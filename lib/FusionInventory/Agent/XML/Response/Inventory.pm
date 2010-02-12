package FusionInventory::Agent::XML::Response::Inventory;

use strict;
use FusionInventory::Agent::XML::Response;
our @ISA = ('FusionInventory::Agent::XML::Response');

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);
    bless ($self, $class);

    return $self;
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

    print STDERR "TODO\n";
    #$self->{accountinfo}->reSetAll($parsedContent->{ACCOUNTINFO});
}
1;
