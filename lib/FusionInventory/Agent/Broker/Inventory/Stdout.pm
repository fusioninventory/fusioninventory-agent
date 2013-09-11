package FusionInventory::Agent::Broker::Inventory::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Broker::Stdout';

use FusionInventory::Agent::XML::Query::Inventory;

sub send {
    my ($self, %params) = @_;

    my $message = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => $self->{deviceid},
        content  => $params{inventory}->getContent()
    );

    print STDOUT $message->getContent();
}

1;
