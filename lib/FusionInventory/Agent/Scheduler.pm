package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

use FusionInventory::Agent::Logger;

my $log_prefix = "[scheduler] ";

sub new {
    my ($class, %params) = @_;

    my $self = {
        client     => $params{client},
        logger     => $params{logger} ||
                      FusionInventory::Agent::Logger->new(),
        lazy       => $params{lazy},
        background => $params{background},
        tasks      => $params{tasks},
        targets    => []
    };
    bless $self, $class;

    return $self;
}

sub addTarget {
    my ($self, $target) = @_;

    push @{$self->{targets}}, $target;
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}}
}

sub getNextTarget {
    my ($self) = @_;

    my $logger = $self->{'logger'};

    return unless @{$self->{targets}};

# Retrieve settings from server
    foreach my $target (@{$self->{targets}}) {
        if ($target->{configValidityNextCheck} < time) {
            $target->planifyEvents(
                client => $self->{client},
                tasks => $self->{tasks}
            );
        }
    }


    if ($self->{background}) {
        # block until a target is eligible to run, then return it
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                foreach my $event (@{$target->{events}}) {
                   if (time > $event->{when}) {
                       return ($target, $event);
                   }
                }
            }
            sleep(5);
        }
    }

    foreach my $target (@{$self->{targets}}) {
        next unless $target->{events};
        next unless @{$target->{events}};
        my $event = shift @{$target->{events}};

        if ($self->{lazy}) {
            # return next target if eligible, nothing otherwise
            if (time > $event->{when}) {
                $logger->info(
                    $log_prefix .
                    "$target->{id}/$event->{task} is ready"
                );
                return ($target, $event);
            } else {
                $logger->info(
                    $log_prefix .
                    "$target->{id} is not ready yet, next server contact " .
                    "planned for " . localtime($target->getNextRunDate())
                );
                push @{$target->{events}}, $event;
                return;
            }
        } elsif ($self->{wait}) {
            # return next target after waiting for a random delay
            my $time = int rand($self->{wait});
            $logger->info(
                $log_prefix .
                "sleeping for $time second(s) because of the wait parameter"
            );
            sleep $time;
            return ($target, $event);
        } else {
            # return next target immediatly
            return ($target, $event);
        }
    }

}


1;
__END__

=head1 NAME

FusionInventory::Agent::Scheduler - A target scheduler

=head1 DESCRIPTION

This is the object used by the agent to schedule various targets.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<lazy>

a flag to ensure targets whose next scheduled execution date has not been
reached yet will get ignored. Only useful when I<background> flag is not set.

=item I<background>

a flag to set if the agent is running as a resident program, aka a daemon in
Unix world, and a service in Windows world (default: false)

=item I<tasks>

a hash reference on a key/val list of available tasks.

=item I<client>

A I<FusionInventory::Agent::HTTP::Client> instance.


=back

=head2 addTarget()

Add a new target to schedule.

=head2 getNextTarget()

Get the next scheduled target.

=head2 getTargets()

Get all targets.
