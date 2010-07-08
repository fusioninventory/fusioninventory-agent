package FusionInventory::Agent::Task::Ping;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Logger;

sub main {
    my ($self) = @_;

    if ($self->{target}->{type} ne 'server') {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $options = $self->{prologresp}->getOptionsInfoByName('PING');
    if (!$options) {
        $self->{logger}->debug("No ping requested in the prolog, exiting");
        return;
    }

    $self->{logger}->debug("Ping ID:". $options->{ID});

    my $network = FusionInventory::Agent::Network->new({
        logger => $self->{logger},
        config => $self->{config},
        target => $self->{target},
    });

    my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        config => $self->{config},
        logger => $self->{logger},
        target => $self->{target},
        msg    => {
            QUERY => 'PING',
            ID    => $options->{ID},
        },
    });

    # is this really useful ?
    $self->{network} = $network;

    $self->{logger}->debug("Pong!");
    $network->send( { message => $message } );

}

1;
