package FusionInventory::Agent::Recipient::Inventory::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Recipient::Stdout';

sub send {
    my ($self, %params) = @_;

    print STDOUT $params{message}->getContent();
}

1;
