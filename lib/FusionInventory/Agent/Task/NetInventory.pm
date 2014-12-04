package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use threads;
use base 'FusionInventory::Agent::Task';

use Encode qw(encode);
use English qw(-no_match_vars);
use Thread::Queue v2.01;
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

our $VERSION = '2.2.0';

# list of devices properties, indexed by XML element name
# the link to a specific OID is made by the model


sub isEnabled {
    my ($self, $response) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("NetInventory task not compatible with local target");
        return;
    }

    my $options = $response->getOptionsInfoByName('SNMPQUERY');
    if (!$options) {
        $self->{logger}->debug("NetInventory task execution not requested");
        return;
    }

    if (!$options->{DEVICE}) {
        $self->{logger}->error("no device defined");
        return;
    }

    $self->{options} = $options;
    return 1;
}

sub run {
    my ($self, %params) = @_;

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
    my $timeout     = $options->{PARAM}->[0]->{TIMEOUT};

    # SNMP credentials
    my $credentials = _getIndexedCredentials($options->{AUTHENTICATION});

    # set internal state
    $self->{pid} = $pid;

    # send initial message to the server
    $self->_sendStartMessage();

    # initialize FIFOs
    my $devices = Thread::Queue->new();
    my $results = Thread::Queue->new();

    foreach my $device (@{$options->{DEVICE}}) {
        $devices->enqueue($device);
    }
    my $size = $devices->pending();

    # no need for more threads than devices to scan
    my $threads_count = $max_threads > $size ? $size : $max_threads;

    my $sub = sub {
        my $id = threads->tid();
        $self->{logger}->debug("[thread $id] creation");

        # run as long as they are devices to process
        while (my $device = $devices->dequeue_nb()) {

            my $result;
            eval {
                $result = $self->_queryDevice(
                    device      => $device,
                    timeout     => $timeout,
                    credentials => $credentials->{$device->{AUTHSNMP_ID}}
                );
            };
            if ($EVAL_ERROR) {
                chomp $EVAL_ERROR;
                $result = {
                    ERROR => {
                        ID      => $device->{ID},
                        TYPE    => $device->{TYPE},
                        MESSAGE => $EVAL_ERROR
                    }
                };
                $self->{logger}->error($EVAL_ERROR);
            }

            $results->enqueue($result) if $result;
        }

        $self->{logger}->debug("[thread $id] termination");
    };

    $self->{logger}->debug("creating $threads_count worker threads");
    for (my $i = 0; $i < $threads_count; $i++) {
        threads->create($sub);
    }

    # as long as some threads are still running...
    while (threads->list(threads::running)) {

        # send available results on the fly
        while (my $result = $results->dequeue_nb()) {
            $self->_sendResultMessage($result);
        }

        # wait for a second
        delay(1);
    }

    # purge remaining results
    while (my $result = $results->dequeue_nb()) {
        $self->_sendResultMessage($result);
    }

    $self->{logger}->debug("cleaning $threads_count worker threads");
    $_->join() foreach threads->list(threads::joinable);

    # send final message to the server
    $self->_sendStopMessage();

    delete $self->{pid};
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

sub _sendStartMessage {
    my ($self) = @_;

    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _sendStopMessage {
    my ($self) = @_;

    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _sendResultMessage {
    my ($self, $result) = @_;

    $self->_sendMessage({
        DEVICE        => $result,
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $credentials = $params{credentials};
    my $device      = $params{device};
    my $logger      = $self->{logger};
    my $id          = threads->tid();
    $logger->debug("[thread $id] scanning $device->{ID}");

    my $snmp;
    if ($device->{FILE}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{FILE}
            );
        };
        die "SNMP emulation error: $EVAL_ERROR" if $EVAL_ERROR;
    } else {
        eval {
            FusionInventory::Agent::SNMP::Live->require();
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                version      => $credentials->{VERSION},
                hostname     => $device->{IP},
                timeout      => $params{timeout} || 15,
                community    => $credentials->{COMMUNITY},
                username     => $credentials->{USERNAME},
                authpassword => $credentials->{AUTHPASSPHRASE},
                authprotocol => $credentials->{AUTHPROTOCOL},
                privpassword => $credentials->{PRIVPASSPHRASE},
                privprotocol => $credentials->{PRIVPROTOCOL},
            );
        };
        die "SNMP communication error: $EVAL_ERROR" if $EVAL_ERROR;
    }

    my $result = getDeviceFullInfo(
         id      => $device->{ID},
         type    => $device->{TYPE},
         snmp    => $snmp,
         model   => $params{model},
         logger  => $self->{logger},
         datadir => $self->{datadir}
    );

    return $result;
}

sub _getIndexedCredentials {
    my ($credentials) = @_;

    # index credentials by their ID
    return { map { $_->{ID} => $_ } @{$credentials} };
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory - Remote inventory support for FusionInventory Agent

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
