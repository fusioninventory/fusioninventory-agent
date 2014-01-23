package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Recipient::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Query;

our $VERSION = $FusionInventory::Agent::VERSION;

sub isEnabled {
    my ($self, %params) = @_;

    return unless
        $self->{controller}->isa('FusionInventory::Agent::Controller::Server');

    my $response = $params{response};

    my $options = $self->getOptionsFromServer(
        $response, 'SNMPQUERY', 'SNMPQuery'
    );
    return unless $options;

    if (!$options->{DEVICE}) {
        $self->{logger}->debug("No device defined in the prolog response");
        return;
    }

    my @credentials;
    foreach my $authentication (@{$options->{AUTHENTICATION}}) {
        my $credential;
        foreach my $key (keys %$authentication) {
            $credential->{lc($key)} = $authentication->{$key};
        }
        push @credentials, $credential;
    }

    $self->{params} = {
        pid         => $options->{PARAM}->[0]->{PID},
        threads     => $options->{PARAM}->[0]->{THREADS_QUERY},
        timeout     => $options->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        models      => $options->{MODEL},
        devices     => $options->{DEVICE},
    };
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("running NetInventory task");

    # use given output recipient,
    # otherwise assume the recipient is a GLPI server
    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Server->new(
            target       => $self->{controller}->getUrl(),
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
    );

    # SNMP models
    my $models = _indexModels($self->{params}->{models});

    # SNMP credentials
    my $credentials = _indexCredentials($self->{params}->{credentials});

    # devices list
    my @devices = @{$self->{params}->{devices}};

    # no need for more threads than devices to scan
    my $threads = $self->{params}->{threads};
    if ($threads > @devices) {
        $threads = @devices;
    }

    my $engine_class = $threads > 1 ?
        'FusionInventory::Agent::Task::NetInventory::Engine::Thread' :
        'FusionInventory::Agent::Task::NetInventory::Engine::NoThread';

    $engine_class->require();

    my $engine = $engine_class->new(
        logger      => $self->{logger},
        datadir     => $self->{datadir},
        credentials => $credentials,
        models      => $models,
        threads     => $threads,
        timeout     => $self->{params}->{timeout},
    );

    # send initial message to the server
    $self->_sendMessage(
        $recipient,
        {
            AGENT => {
                START        => 1,
                AGENTVERSION => $FusionInventory::Agent::VERSION
            },
            MODULEVERSION => $FusionInventory::Agent::VERSION,
            PROCESSNUMBER => $self->{params}->{pid}
        }
    );

    # proceed each given device
    my @results = $engine->query(@devices);

    foreach my $result (@results) {
        my $data = {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{params}->{pid}
        };
        $self->_sendMessage($recipient, $data);
    }

    $engine->finish();

    # send final message to the server
    $self->_sendMessage(
        $recipient,
        {
            AGENT => {
                END => 1,
            },
            MODULEVERSION => $FusionInventory::Agent::VERSION,
            PROCESSNUMBER => $self->{params}->{pid}
        }
    );
}

sub _sendMessage {
    my ($self, $recipient, $content) = @_;

   my $message = FusionInventory::Agent::XML::Query->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => $content
   );

   $recipient->send(message => $message);
}

sub _indexModels {
    my ($models) = @_;

    foreach my $model (@{$models}) {
        # index oids
        $model->{oids} = {
            map { $_->{OBJECT} => $_->{OID} }
            @{$model->{GET}}, @{$model->{WALK}}
        };
    }

    # index models by their ID
    return { map { $_->{ID} => $_ } @{$models} };
}

sub _indexCredentials {
    my ($credentials) = @_;

    return unless $credentials;

    # index credentials by their ID
    return { map { $_->{id} => $_ } @{$credentials} };
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory - Network inventory task

=head1 DESCRIPTION

This task extracts various information from remote hosts through SNMP
protocol:

=over

=item *

printer cartridges and counters status

=item *

router/switch ports status

=item *

relations between devices and router/switch ports

=back

This task requires a GLPI server with FusionInventory plugin.

=head1 AUTHORS

Copyright (C) 2009 David Durieux
Copyright (C) 2010-2013 FusionInventory Team
