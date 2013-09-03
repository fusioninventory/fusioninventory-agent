package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use Encode qw(encode);
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

our $VERSION = '2.2.0';

sub isEnabled {
    my ($self, $response) = @_;

    return unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    my $options = $self->getOptionsFromServer(
        $response, 'SNMPQUERY', 'SNMPQuery'
    );
    return unless $options;

    if (!$options->{DEVICE}) {
        $self->{logger}->debug("No device defined in the prolog response");
        return;
    }

    $self->{options} = $options;
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("FusionInventory NetInventory task $VERSION");

    # task-specific client, if needed
    $self->{client} = FusionInventory::Agent::HTTP::Client::OCS->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    ) if !$self->{client};

    my $options     = $self->{options};
    my $pid         = $options->{PARAM}->[0]->{PID};
    my $max_threads = $options->{PARAM}->[0]->{THREADS_QUERY};

    # SNMP models
    my $models = _getIndexedModels($options->{MODEL});

    # SNMP credentials
    my $credentials = _getIndexedCredentials($options->{AUTHENTICATION});

    # devices list
    my @devices = @{$options->{DEVICE}};

    # no need for more threads than devices to scan
    if ($max_threads > @devices) {
        $max_threads = @devices;
    }

    my $engine_class = $max_threads > 1 ?
        'FusionInventory::Agent::Task::NetInventory::Egine::Thread' :
        'FusionInventory::Agent::Task::NetInventory::Engine::NoThread';

    $engine_class->require();

    my $engine = $engine_class->new(
        logger      => $self->{logger},
        credentials => $credentials,
        models      => $models,
        threads     => $max_threads
    );

    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

    my @results = $engine->query(@devices);

    foreach my $result (@results) {
        my $data = {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $pid
        };
        $self->_sendMessage($data);
    }

    $engine->finish();

    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });
}

sub _sendMessage {
    my ($self, $content) = @_;


   my $message = FusionInventory::Agent::XML::Query->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => $content
   );

   $self->{client}->send(
       url     => $self->{target}->getUrl(),
       message => $message
   );
}

sub _getIndexedModels {
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

sub _getIndexedCredentials {
    my ($credentials) = @_;

    # index credentials by their ID
    return { map { $_->{ID} => $_ } @{$credentials} };
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
Copyright (C) 2010-2012 FusionInventory Team
