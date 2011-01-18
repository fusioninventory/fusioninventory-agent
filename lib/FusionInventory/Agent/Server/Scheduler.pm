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
            tick => sub { $self->checkAllJobs() },
            run  => sub { $self->runAllJobs() },
        }
    );

    $self->{logger}->info(
        "[scheduler] Scheduler started"
    );

    return $self;
}

sub scheduleJobs {
    my ($self, $offset) = @_;

    foreach my $job ($self->{state}->getJobs()) {
        $job->scheduleNextRun($offset);
    }
}


sub checkAllJobs {
    my ($self) = @_;

    my $time = time();
    foreach my $job ($self->{state}->getJobs()) {
        $self->runJob($job) if $time > $job->getNextRunDate();
    }
}

sub runAllJobs {
    my ($self) = @_;

    foreach my $job ($self->{state}->getJobs()) {
        $self->runJob($job);
    }
}

sub runJob {
    my ($self, $job) = @_;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Scheduler - Agent scheduler

=head1 DESCRIPTION

This is the agent scheduler, managing jobs.

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

=head2 scheduleJobs()

Call scheduleNextRun() on all jobs.

=head2 checkAllJobs()

Run all jobs whose next execution date has been reached.

=head2 runAllJobs()

Run all jobs.

=head2 runJob($job)

Run a single job.
