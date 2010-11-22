package FusionInventory::Agent::Scheduler;

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
                print "Scheduler Start\n";
                $_[KERNEL]->alias_set("scheduler");
            },
            runAllNow => sub { $self->runAllNow() },
	    targetIsDone => sub {
                return;
	    } 
        }
    );

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

    # block until a target is eligible to run, then return it
    while (1) {
        foreach my $target (@{$self->{targets}}) {
            if (time > $target->getNextRunDate()) {
                return $target;
            }
        }
        sleep(10);
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

sub runAllNow {
    my ($self) = @_;

    my $logger = $self->{logger};
    foreach my $target (@{$self->{targets}}) {
        $logger->info("Calling ".$target->getDescriptionString());
        POE::Kernel->call( $target->{session}, 'runNow' );
        $logger->info("End of call ".$target->getDescriptionString());
    }
    $logger->info("End of runAllNowl()");

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
