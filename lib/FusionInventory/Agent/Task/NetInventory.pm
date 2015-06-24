package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use File::Basename;
use Parallel::ForkManager;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::SNMP::Client;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $config = $params{spec}->{config};

    my @credentials;
    foreach my $authentication (@{$config->{AUTHENTICATION}}) {
        my $credentials;
        foreach my $key (keys %$authentication) {
            next unless $authentication->{$key};
            my $newkey =
                $key eq 'AUTHPASSPHRASE' ? 'authpassword' :
                $key eq 'PRIVPASSPHRASE' ? 'privpassword' :
                                            lc($key)      ;
            $credentials->{$newkey} = $authentication->{$key};
        }
        my $id = delete $credentials->{id};
        $credentials[$id] = $credentials;
    }

    my @jobs;
    foreach my $device (@{$config->{DEVICE}}) {
        my $job;
        foreach my $key (keys %$device) {
                 if ($key eq 'AUTHSNMP_ID') {
                 my $credentials = $credentials[$device->{AUTHSNMP_ID}];
                 if ($credentials) {
                     $job->{$_} = $credentials->{$_} foreach keys %$credentials;
                 } else {
                     die "invalid AUTHSNMP_ID $device->{AUTHSNMP_ID}";
                 }
            } elsif ($key eq 'IP') {
                $job->{host} = $device->{IP};
            } elsif ($key eq 'ID' || $key eq 'TYPE' || $key eq 'ENTITY') {
                $job->{lc($key)} = $device->{$key};
            }
        }
        push @jobs, $job;
    }

    return (
        pid     => $config->{PARAM}->[0]->{PID},
        workers => $config->{PARAM}->[0]->{THREADS_QUERY},
        timeout => $config->{PARAM}->[0]->{TIMEOUT},
        jobs    => \@jobs
    );
}

sub run {
    my ($self, %params) = @_;

    my $target  = $params{target}
        or die "no target provided, aborting";
    my @jobs = @{$self->{config}->{jobs}}
        or die "no hosts provided, aborting";
    my $max_workers = $self->{config}->{workers} || 0;
    my $pid         = $self->{config}->{pid}     || 1;
    my $timeout     = $self->{config}->{timeout} || 15;

    # set internal state
    $self->{pid} = $pid;
    $self->{target} = $target;

    # send initial message to the server
    $self->_sendStartMessage();

    # no need for more workers than jobs to process
    my $workers_count = $max_workers > @jobs ? @jobs : $max_workers;
    my $manager = Parallel::ForkManager->new($workers_count);

    foreach my $device (@jobs) {
        $manager->start() and next;

        eval {
            $self->_queryDevice(
                device  => $device,
                timeout => $timeout,
            );
        };
        if ($EVAL_ERROR) {
            $self->_sendErrorMessage($device, $EVAL_ERROR);
            $self->{logger}->error($EVAL_ERROR);
        }

        $manager->finish();
    }

    $manager->wait_all_children();

    # send final message to the server
    $self->_sendStopMessage();

    delete $self->{pid};
    delete $self->{target};
}

sub abort {
    my ($self) = @_;

    $self->_sendStopMessage() if $self->{pid};
    $self->SUPER::abort();
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $device = $params{device};
    my $logger = $self->{logger};
    my $source = $device->{host} || basename($device->{file});
    $logger->debug(
        '%sprocessing %s',
        $self->{config}->{workers} ? "[worker $PID] " : '',
        $source
    );

    my $snmp;

    if ($device->{file}) {
        FusionInventory::Agent::SNMP::Client::Virtual->require();
        $snmp = FusionInventory::Agent::SNMP::Client::Virtual->new(
            file => $device->{file}
        );
    } else {
        $snmp = FusionInventory::Agent::SNMP::Client->new(
            timeout      => $params{timeout},
            hostname     => $device->{host},
            version      => $device->{version},
            community    => $device->{community},
            username     => $device->{username},
            authpassword => $device->{authpassphrase},
            authprotocol => $device->{authprotocol},
            privpassword => $device->{privpassphrase},
            privprotocol => $device->{privprotocol},
        );
    }

    my $result = getDeviceFullInfo(
         id      => $device->{id},
         type    => $device->{type},
         snmp    => $snmp,
         logger  => $self->{logger},
         dbdir   => $self->{config}->{datadir} . '/db',
         config  => $self->{config}
    );
    $self->_sendResultMessage($result, $source);
}

sub _sendStartMessage {
    my ($self) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
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
       deviceid => $self->{config}->{deviceid},
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
    my ($self, $result, $source) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'SNMPQUERY',
        content  => {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(
        message  => $message,
        filename => sprintf('netinventory_%s.xml', $source),
    );
}

sub _sendErrorMessage {
    my ($self, $device, $error) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'SNMPQUERY',
        content  => {
            DEVICE => {
                ERROR => {
                    ID      => $device->{id},
                    TYPE    => $device->{type},
                    MESSAGE => $error
                }
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(
        message  => $message,
    );
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory - Remote inventory support

=head1 DESCRIPTION

This module allows the FusionInventory agent to retrieve an inventory of a
remote host through SNMP protocol.
