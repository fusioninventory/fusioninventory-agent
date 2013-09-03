package FusionInventory::Agent::Task::NetInventory::Engine::Thread;

use strict;
use warnings;
use threads;
use threads::shared;
use base 'FusionInventory::Agent::Task::NetInventory::Engine';

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use UNIVERSAL::require;

use FusionInventory::Agent::Tools;

# needed for perl < 5.10.1 compatbility
if ($threads::shared::VERSION < 1.21) {
    FusionInventory::Agent::Threads->use();
}

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    # create shared variables for synchronisation
    my (@devices, @results, @states);
    $self->{devices} = share(@devices);
    $self->{results} = share(@results);
    $self->{states}  = share(@states);

    # create all threads in START state
    for (my $i = 0; $i < $params{threads}; $i++) {
        $self->{states}->[$i] = START;

        threads->create(
            '_queryDevices',
            $self,
        )->detach();
    }
}

sub query {
    my ($self, @devices) = @_;

    push @{$self->{devices}}, @devices;

    # set all threads in RUN state
    $_ = RUN foreach @{$self->{states}};

    # wait for all threads to reach STOP state
    while (any { $_ != STOP } @{$self->{states}}) {
        delay(1);
    }

    my @results;
    while (@{$self->{results}}) {
        push @results, pop @{$self->{results}};
    }

    return @results;
}

sub finish {
    my ($self) = @_;
    
    # set all threads in EXIT state
    $_ = EXIT foreach @{$self->{states}};
    delay(1);
}

sub _queryDevices {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();

    $logger->debug("Thread $id created in PAUSE state");

    # start: wait for state to change
    while ($self->{states}->[$id - 1] == START) {
        delay(1);
    }

    OUTER: while (1) {
        # run: process available addresses until exhaustion
        $logger->debug("Thread $id switched to RUN state");

        while (my $device = do { lock @{$self->{devices}}; shift @{$self->{devices}}; }) {

            my $result = $self->_queryDevice($device);

            $result = {
                ERROR => {
                        ID      => $device->{ID},
                        TYPE    => $device->{TYPE},
                        MESSAGE => "No response from remote host"
                    }
            } if !$result;

            if ($result) {
                lock $self->{results};
                push @{$self->{results}}, shared_clone($result);
            }
        }

        # stop: wait for state to change
        $self->{states}->[$id - 1] = STOP;
        $logger->debug("Thread $id switched to STOP state");
        while ($self->{states}->[$id - 1] == STOP) {
            delay(1);
        }

        # exit: exit thread
        last OUTER if $self->{states}->[$id - 1] == EXIT;
    }

    $logger->debug("Thread $id deleted");
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Engine::Thread - Threaded network inventory engine
