package FusionInventory::Agent::Broker::Inventory::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Broker::Server';

use FusionInventory::Agent::XML::Query::Inventory;

sub send {
    my ($self, %params) = @_;

    my $message = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => $self->{deviceid},
        content  => $params{inventory}->getContent()
    );

    $self->{client}->send(
        url     => $self->{url},
        message => $message
    );
}

1;
