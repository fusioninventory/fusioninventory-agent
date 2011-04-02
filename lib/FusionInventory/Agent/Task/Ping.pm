package FusionInventory::Agent::Task::Ping;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::XML::Query::SimpleMessage;

our $VERSION = '1.0';

sub main {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $response = $self->{prologresp};
    if (!$response) {
        $self->{logger}->debug("No server response. Exiting...");
        return;
    }

    my $options = $response->getOptionsInfoByName('PING');
    if (!$options) {
        $self->{logger}->debug("No ping requested in the prolog, exiting");
        return;
    }

    $self->{logger}->debug("Ping ID:". $options->{ID});

    my $transmitter = FusionInventory::Agent::Transmitter->new({
        logger       => $self->{logger},
        user         => $self->{config}->{user},
        password     => $self->{config}->{password},
        proxy        => $self->{config}->{proxy},
        ca_cert_file => $self->{config}->{'ca-cert-file'},
        ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
        no_ssl_check => $self->{config}->{'no-ssl-check'},
    });

    my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        logger          => $self->{logger},
        deviceid        => $self->{target}->{deviceid},
        currentDeviceid => $self->{target}->{currentDeviceid},
        msg      => {
            QUERY => 'PING',
            ID    => $options->{ID},
        },
    });

    $self->{logger}->debug("Pong!");
    $transmitter->send({
        url     => $self->{target}->getUrl(),
        message => $message
    });

}

1;
