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

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if (!$response) {
        $self->{logger}->debug("Task not compatible with a local controller");
        return;
    }

    my $options = $response->getOptionsInfoByName('SNMPQUERY');
    if (!$options) {
        $self->{logger}->debug("Task not scheduled");
        return;
    }
    return unless $options;

    my @credentials;
    foreach my $authentication (@{$options->{AUTHENTICATION}}) {
        my $credential;
        foreach my $key (keys %$authentication) {
            $credential->{lc($key)} = $authentication->{$key};
        }
        push @credentials, $credential;
    }

    my @devices;
    foreach my $authentication (@{$options->{DEVICE}}) {
        my $device;
        foreach my $key (keys %$authentication) {
            $device->{lc($key)} = $authentication->{$key};
        }
        push @devices, $device;
    }

    my @models;
    foreach my $item (@{$options->{MODEL}}) {
        my $model = {
            id   => $item->{ID},
            name => $item->{NAME},
            oids => {
                map { $_->{OBJECT} => $_->{OID} }
                @{$item->{GET}}, @{$item->{WALK}}
            }
        };
        push @models, $model;
    }

    return (
        pid         => $options->{PARAM}->[0]->{PID},
        threads     => $options->{PARAM}->[0]->{THREADS_QUERY},
        timeout     => $options->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        models      => \@models,
        devices     => \@devices
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->info("Running NetInventory task");

    my @devices = @{$self->{params}->{devices}};
    if (!@devices) {
        $self->{logger}->error("no devices given, aborting");
        return;
    }
    $self->{logger}->info("got @devices devices to inventory");

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
        datadir     => $self->{params}->{datadir},
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
        },
        1,
        'inventory_start'
    );

    # proceed each given device
    my @results = $engine->query(@devices);

    my $size = 1;
    foreach my $result (@results) {
        my $hint = 'inventory_' . $size++;
        my $data = {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{params}->{pid}
        };
        $self->_sendMessage($recipient, $data, 0, $hint);
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
        },
        1,
        'inventory_end'
    );
}

sub _sendMessage {
    my ($self, $recipient, $content, $control) = @_;

   my $message = FusionInventory::Agent::XML::Query->new(
       deviceid => $self->{params}->{deviceid},
       query    => 'SNMPQUERY',
       content  => $content
   );

   $recipient->send(message => $message, control => $control);
}

sub _indexModels {
    my ($models) = @_;

    return unless $models;

    # index models by their ID
    return { map { $_->{id} => $_ } @{$models} };
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
