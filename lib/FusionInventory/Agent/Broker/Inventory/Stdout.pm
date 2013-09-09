package FusionInventory::Agent::Broker::Inventory::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Broker::Stdout';

use FusionInventory::Agent::XML::Query::Inventory;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{deviceid} = $params{deviceid};
    return $self;
}

sub send {
    my ($self, %params) = @_;

    my $message = FusionInventory::Agent::XML::Query::Inventory->new(
        deviceid => $self->{deviceid},
        content  => $params{inventory}->getContent()
    );

    print STDOUT $message->getContent();
}

1;
