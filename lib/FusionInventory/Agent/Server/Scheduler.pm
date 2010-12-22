package FusionInventory::Agent::Server::Scheduler;

use strict;
use warnings;

use POE;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger  => $params{logger} || FusionInventory::Agent::Logger->new(),
        state   => $params{state},
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
        "[scheduler] Scheduler started"
    );

    return $self;
}

sub scheduleTargets {
    my ($self, $offset) = @_;

    foreach my $target ($self->{state}->getTargets()) {
        $target->scheduleNextRun($offset);
    }
}


sub checkAllTargets {
    my ($self) = @_;

    my $time = time();
    foreach my $target ($self->{state}->getTargets()) {
        $self->runTarget($target) if $time > $target->getNextRunDate();
    }
}

sub runAllTargets {
    my ($self) = @_;

    foreach my $target ($self->{state}->getTargets()) {
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

=item I<state>

the server state object

=back

=head2 scheduleTargets()

Call scheduleNextRun() on all targets.

=head2 checkAllTargets()

Run all targets whose next execution date has been reached.

=head2 runAllTargets()

Run all targets.

=head2 runTarget($target)

Run a single target.
