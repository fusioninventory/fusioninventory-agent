package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger     => $params->{logger},
        lazy       => $params->{lazy},
        wait       => $params->{wait},
        background => $params->{background},
        targets    => []
    };

    bless $self, $class;

    return $self;
}

sub addTarget {
    my ($self, $target) = @_;

    push @{$self->{targets}}, $target;
}

sub getNextTarget {
    my ($self) = @_;

    my $logger = $self->{logger};

    return unless @{$self->{targets}};

    if ($self->{background}) {
        # block until a target is eligible to run, then return it
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                if (time > $target->getNextRunDate()) {
                    return $target;
                }
            }
            sleep(10);
        }
    } else {
        my $target = shift @{$self->{targets}};

        # return next target if eligible, nothing otherwise
        if ($self->{lazy}) {
            if (time > $target->getNextRunDate()) {
                $logger->debug("Processing $target->{path}");
                return $target;
            } else {
                $logger->info(
                    "Nothing to do for $target->{path}. Next server contact " .
                    "planned for " . localtime($target->getNextRunDate())
                );
                return;
            }
        }

        # return next target after waiting for a random delay
        if ($self->{wait}) {
            my $wait = int rand($self->{wait});
            $logger->info(
                "Going to sleep for $wait second(s) because of the wait " .
                "parameter"
            );
            sleep($wait);
            return $target;
        }

        # return next target immediatly
        return $target;
    }

    # should never get reached
    return;
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}}
}

sub scheduleTargets {
    my ($self, $offset) = @_;

    foreach my $target (@{$self->{targets}}) {
        $target->scheduleNextRun($offset);
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Scheduler - A target scheduler

=head1 DESCRIPTION

This is the object used by the agent to schedule various targets.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item logger (mandatory)

=item lazy

=item wait

=item background

=back
