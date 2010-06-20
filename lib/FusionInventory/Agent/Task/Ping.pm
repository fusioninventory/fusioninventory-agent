package FusionInventory::Agent::Task::Ping;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Base';

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Logger;

sub main {
    my $self = FusionInventory::Agent::Task::Ping->new();

    if ($self->{target}->{type} ne 'server') {
        $self->{logger}->debug("No server. Exiting...");
        exit(0);
    }

    my $options = $self->{data}->{prologresp}->getOptionsInfoByName('PING');
    return unless $options;
    my $option = shift @$options;
    return unless $option;

    $self->{logger}->debug("Ping ID:". $option->{ID});

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
            ID    => $option->{ID},
        },
    });

    # is this really useful ?
    $self->{network} = $network;

    $self->{logger}->debug("Pong!");
    $network->send( { message => $message } );

}

1;
