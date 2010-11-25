package FusionInventory::Agent::Task::Ping;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::XML::Query::SimpleMessage;

sub run {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $options = $self->{prologresp}->getOptionsInfoByName('PING');
    if (!$options) {
        $self->{logger}->debug("No ping requested in the prolog, exiting");
        return;
    }

    $self->{logger}->debug("Ping ID:". $options->{ID});

    my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        logger   => $self->{logger},
        deviceid => $self->{target}->{deviceid},
        msg      => {
            QUERY => 'PING',
            ID    => $options->{ID},
        },
    );

    $self->{logger}->debug("Pong!");
    $self->{transmitter}->send( { message => $message } );

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Ping - The ping task for FusionInventory 

=head1 DESCRIPTION

This task just send a simple message to the server.
