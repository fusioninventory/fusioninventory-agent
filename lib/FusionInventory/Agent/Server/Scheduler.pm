package FusionInventory::Agent::Server::Scheduler;

use strict;
use warnings;

use POE;

use FusionInventory::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger  => $params{logger} || FusionInventory::Logger->new(),
        targets => []
    };

    bless $self, $class;

    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[KERNEL]->alias_set('scheduler');
                $_[KERNEL]->delay_set('tick', 1);
            },
            tick => sub { $self->checkAllTargets() },
            run  => sub { $self->runAllTargets() },
        }
    );

    $self->{logger}->info(
        "Scheduler started"
    );

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


sub scheduleTargets {
    my ($self, $offset) = @_;

    foreach my $target (@{$self->{targets}}) {
        $target->scheduleNextRun($offset);
    }
}


sub checkAllTargets {
    my ($self) = @_;

    my $time = time();
    foreach my $target (@{$self->{targets}}) {
        $self->runTarget($target) if $time > $target->getNextRunDate();
    }
}

sub runAllTargets {
    my ($self) = @_;

    foreach my $target (@{$self->{targets}}) {
        $self->runTarget($target);
    }
}

sub runTarget {
    my ($self, $target) = @_;
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

=back

=head2 addTarget()

Add a new target to schedule.

=head2 getNextTarget()

Get the next scheduled target.

=head2 getTargets()

Get all targets.

=head2 scheduleTargets()

Call scheduleNextRun() on all targets.
