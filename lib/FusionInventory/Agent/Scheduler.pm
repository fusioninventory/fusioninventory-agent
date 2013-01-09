package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger     => $params{logger} ||
                      FusionInventory::Agent::Logger->new(),
        lazy       => $params{lazy},
        background => $params{background},
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

    my $logger = $self->{'logger'};

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
    }

    my $target = shift @{$self->{targets}};

    if ($self->{lazy}) {
        # return next target if eligible, nothing otherwise
        if (time > $target->getNextRunDate()) {
            $logger->debug("[scheduler] $target->{id} is ready");
            return $target;
        } else {
            $logger->info(
                "$target->{id} is not ready yet, next server " .
                "contact planned for " . localtime($target->getNextRunDate())
            );
            return;
        }
    }

    # return next target immediatly
    return $target;
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}}
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

=back

=head2 addTarget()

Add a new target to schedule.

=head2 getNextTarget()

Get the next scheduled target.

=head2 getTargets()

Get all targets.
