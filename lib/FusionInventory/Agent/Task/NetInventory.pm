package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use threads;
use threads::shared;
use base 'FusionInventory::Agent::Task';

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use Encode qw(encode);
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

# needed for perl < 5.10.1 compatbility
if ($threads::shared::VERSION < 1.21) {
    FusionInventory::Agent::Threads->use();
}

our $VERSION = '2.2.0';

# list of devices properties, indexed by XML element name
# the link to a specific OID is made by the model


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
    my $timeout     = $options->{PARAM}->[0]->{TIMEOUT};

    # SNMP models
    my $models = _getIndexedModels($options->{MODEL});

    # SNMP credentials
    my $credentials = _getIndexedCredentials($options->{AUTHENTICATION});

    # create the required number of threads, sharing variables
    # for synchronisation
    my @devices :shared = map { shared_clone($_) } @{$options->{DEVICE}};
    my @results :shared;
    my @states  :shared;

    # no need for more threads than devices to scan
    if ($max_threads > @devices) {
        $max_threads = @devices;
    }

    #===================================
    # Create all Threads
    #===================================
    for (my $i = 0; $i < $max_threads; $i++) {
        $states[$i] = START;

        threads->create(
            '_queryDevices',
            $self,
            \$states[$i],
            \@devices,
            \@results,
            $models,
            $credentials,
            $timeout,
        )->detach();
    }

    # send initial message to the server
    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

    # set all threads in RUN state
    $_ = RUN foreach @states;

    # wait for all threads to reach EXIT state
    while (any { $_ != EXIT } @states) {
        delay(1);

        # send results to the server
        while (my $result = do { lock @results; shift @results; }) {
            my $data = {
                DEVICE        => $result,
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid
            };
            $self->_sendMessage($data);
        }
    }

    # send final message to the server
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

sub _queryDevices {
    my ($self, $state, $devices, $results, $models, $credentials, $timeout) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();

    $logger->debug("Thread $id created in PAUSE state");

    # start: wait for state to change
    while ($$state == START) {
        delay(1);
    }

    # run: process available addresses until exhaustion
    $logger->debug("Thread $id switched to RUN state");

    while (my $device = do { lock @{$devices}; shift @{$devices}; }) {

        my $result = $self->_queryDevice(
            device      => $device,
            timeout     => $timeout,
            model       => $models->{$device->{MODELSNMP_ID}},
            credentials => $credentials->{$device->{AUTHSNMP_ID}}
        );

        $result = {
            ERROR => {
                    ID      => $device->{ID},
                    TYPE    => $device->{TYPE},
                    MESSAGE => "No response from remote host"
                }
        } if !$result;

        if ($result) {
            lock $results;
            push @$results, shared_clone($result);
        }

        delay(1);
    }

    $$state = EXIT;
    $logger->debug("Thread $id switched to EXIT state");
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $credentials = $params{credentials};
    my $device      = $params{device};
    my $logger      = $self->{logger};
    my $id          = threads->tid();
    $logger->debug("thread $id: scanning $device->{ID}");

    my $snmp;
    if ($device->{FILE}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{FILE}
            );
        };
        if ($EVAL_ERROR) {
            $logger->error("Unable to create SNMP session for $device->{FILE}: $EVAL_ERROR");
            return;
        }
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
        if ($EVAL_ERROR) {
            $logger->error("Unable to create SNMP session for $device->{IP}: $EVAL_ERROR");
            return;
        }
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
