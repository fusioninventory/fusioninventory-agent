package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        client     => $params{client},
        logger     => $params{logger} ||
                      FusionInventory::Agent::Logger->new(),
        lazy       => $params{lazy},
        wait       => $params{wait},
        background => $params{background},
        tasks       => $params{tasks},
        targets    => []
    };
    bless $self, $class;

    return $self;
}

sub addTarget {
    my ($self, $target) = @_;

#    $target->prepareTasksExecPlan(client => $self->{client}, tasks => $self->{tasks});

#    print Dumper($target->{tasksExecPlan});

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

# Read settings from server
    foreach my $target (@{$self->{targets}}) {
        if ($target->{configValidityNextCheck} < time) {
            $target->prepareTasksExecPlan(client => $self->{client}, tasks => $self->{tasks});
        }
    }


    if ($self->{background}) {
        # block until a target is eligible to run, then return it
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                my $tasksExecPlan = $target->getTaskExecPlan();
                foreach my $a (@$tasksExecPlan) {
                   if (time > $a->{when}) {
                       return ($target, $a);
                   }
                }
            }
            print "sleep 10\n";
            sleep(10);
        }
    }

    foreach my $target (@{$self->{targets}}) {
        next unless @{$target->{tasksExecPlan}};
        # Gonéri: I'm not fan of $tasksExecPlan name
        my $tasksExecPlan = shift @{$target->{tasksExecPlan}};
        use Data::Dumper;
        print Dumper($tasksExecPlan);

        if ($self->{lazy}) {
# return next target if eligible, nothing otherwise
            if (time > $tasksExecPlan->{when}) {
                $logger->debug("[scheduler] ".
                        $target->{id}.
                        "/".
                        $tasksExecPlan->{task}.
                        " is ready");
                return ($target, $tasksExecPlan);
            } else {
                $logger->info(
                        "$target->{id} is not ready yet, next server " .
                        "contact planned for " . localtime($target->getNextRunDate())
                        );
                push @{$target->{tasksExecPlan}}, $tasksExecPlan;
                return;
            }
        } elsif ($self->{wait}) {
# return next target after waiting for a random delay
            my $time = int rand($self->{wait});
            $logger->info(
                    "[scheduler] sleeping for $time second(s) because of the wait " .
                    "parameter"
                    );
            print "let's sleep $time\n";
            sleep $time;
            return ($target, $tasksExecPlan);
        } else {
# return next target immediatly
            return ($target, $tasksExecPlan);
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

=item I<wait>

a number of second to wait before returning each target. Only useful when
I<background> flag is not set.

=item I<background>

a flag to set if the agent is running as a resident program, aka a daemon in
Unix world, and a service in Windows world (default: false)

=item I<tasks>

a hash reference on a key/val list of avalaible tasks.

=item I<client>

A I<FusionInventory::Agent::HTTP::Client::Fusion> instance.


=back

=head2 addTarget()

Add a new target to schedule.

=head2 getNextTarget()

Get the next scheduled target.

=head2 getTargets()

Get all targets.
