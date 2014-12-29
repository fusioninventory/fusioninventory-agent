package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use threads;
use base 'FusionInventory::Agent::Task';

use Encode qw(encode);
use English qw(-no_match_vars);
use List::Util qw(first);
use Thread::Queue v2.01;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $prolog = $params{prolog};
    return unless $prolog;
    return unless $prolog->{OPTION};

    my $task =
        first { $_->{NAME} eq 'SNMPQUERY' }
        @{$prolog->{OPTION}};

    return unless $task;

    my @credentials;
    foreach my $item (@{$task->{AUTHENTICATION}}) {
        my $credentials;
        foreach my $key (keys %$item) {
            my $newkey =
                $key eq 'AUTHPASSPHRASE' ? 'authpassword' :
                $key eq 'PRIVPASSPHRASE' ? 'privpassword' :
                                            lc($key)      ;
            $credentials->{$newkey} = $item->{$key};
        }
        push @credentials, $credentials;
    }

    my @devices;
    foreach my $item (@{$task->{DEVICE}}) {
        my $device;
        foreach my $key (keys %$item) {
            my $newkey = $key eq 'IP' ? 'host' : lc($key);
            $device->{$newkey} = $item->{$key};
        }
        push @devices, $device;
    }

    return (
        pid         => $task->{PARAM}->[0]->{PID},
        threads     => $task->{PARAM}->[0]->{THREADS_QUERY},
        timeout     => $task->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        devices     => \@devices
    );
}

sub run {
    my ($self, %params) = @_;

    my $target  = $params{target}
        or die "no target provided, aborting";
    my @devices = @{$self->{config}->{devices}}
        or die "no devices provided, aborting";
    my $credentials = _indexCredentials($self->{config}->{credentials});
    my $max_threads = $self->{config}->{threads} || 1;
    my $pid         = $self->{config}->{pid}     || 1;
    my $timeout     = $self->{config}->{timeout} || 15;

    # set internal state
    $self->{pid} = $pid;
    $self->{target} = $target;

    # send initial message to the server
    $self->_sendStartMessage();

    # initialize FIFOs
    my $devices_queue = Thread::Queue->new();
    my $results_queue = Thread::Queue->new();

    foreach my $device (@devices) {
        $devices_queue->enqueue($device);
    }
    my $size = $devices_queue->pending();

    # no need for more threads than devices to scan
    my $threads_count = $max_threads > $size ? $size : $max_threads;

    my $sub = sub {
        my $id = threads->tid();
        $self->{logger}->debug("[thread $id] creation");

        # run as long as they are devices to process
        while (my $device = $devices_queue->dequeue_nb()) {

            my $result;
            eval {
                $result = $self->_queryDevice(
                    device      => $device,
                    timeout     => $timeout,
                    credentials => $credentials->{$device->{authsnmp_id}}
                );
            };
            if ($EVAL_ERROR) {
                chomp $EVAL_ERROR;
                $result = {
                    ERROR => {
                        ID      => $device->{id},
                        TYPE    => $device->{type},
                        MESSAGE => $EVAL_ERROR
                    }
                };
                $self->{logger}->error($EVAL_ERROR);
            }

            $results_queue->enqueue($result) if $result;
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
        while (my $result = $results_queue->dequeue_nb()) {
            $self->_sendResultMessage($result);
        }

        # wait for a second
        delay(1);
    }

    # purge remaining results
    while (my $result = $results_queue->dequeue_nb()) {
        $self->_sendResultMessage($result);
    }

    $self->{logger}->debug("cleaning $threads_count worker threads");
    $_->join() foreach threads->list(threads::joinable);

    # send final message to the server
    $self->_sendStopMessage();

    delete $self->{pid};
    delete $self->{target};
}

sub _sendStartMessage {
    my ($self) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => {
           AGENT => {
               START        => 1,
               AGENTVERSION => $FusionInventory::Agent::VERSION,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(message => $message);
}

sub _sendStopMessage {
    my ($self) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => {
           AGENT => {
               END => 1,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
       }
    );

    $self->{target}->send(message => $message);
}

sub _sendResultMessage {
    my ($self, $result) = @_;

    my $origin = delete $result->{origin};

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{deviceid},
        query    => 'SNMPQUERY',
        content  => {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(
        message  => $message,
        filename => sprintf('netinventory_%s.xml', $origin),
    );
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $credentials = $params{credentials};
    my $device      = $params{device};
    my $logger      = $self->{logger};
    my $id          = threads->tid();
    $logger->debug("[thread $id] scanning $device->{id}");

    my $snmp;
    if ($device->{file}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{file}
            );
        };
        die "SNMP emulation error: $EVAL_ERROR" if $EVAL_ERROR;
    } else {
        eval {
            FusionInventory::Agent::SNMP::Live->require();
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                version      => $credentials->{version},
                hostname     => $device->{ip},
                timeout      => $params{timeout},
                community    => $credentials->{community},
                username     => $credentials->{username},
                authpassword => $credentials->{authpassphrase},
                authprotocol => $credentials->{authprotocol},
                privpassword => $credentials->{privpassphrase},
                privprotocol => $credentials->{privprotocol},
            );
        };
        die "SNMP communication error: $EVAL_ERROR" if $EVAL_ERROR;
    }

    my $result = getDeviceFullInfo(
         id      => $device->{id},
         type    => $device->{type},
         snmp    => $snmp,
         model   => $params{model},
         logger  => $self->{logger},
         datadir => $self->{datadir},
         origin  => $device->{ip} || $device->{file}
    );

    return $result;
}

sub _indexCredentials {
    my ($credentials) = @_;

    return { map { $_->{id} => $_ } @$credentials };
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory - Remote inventory support

=head1 DESCRIPTION

This module allows the FusionInventory agent to retrieve an inventory of a
remote host through SNMP protocol.
