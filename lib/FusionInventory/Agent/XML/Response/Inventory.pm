package FusionInventory::Agent::XML::Response::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Response';

sub isAccountUpdated {
    my $self = shift;

    my $parsedContent = $self->getParsedContent();

    if (
        $parsedContent &&
        exists $parsedContent->{RESPONSE} &&
        $parsedContent->{RESPONSE} eq 'ACCOUNT_UPDATE'
    ) {
	return 1;
    } else {
	return 0;
    }

}

1;
