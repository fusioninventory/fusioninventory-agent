package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger     => $params->{logger},
        lazy       => $params->{lazy},
        wait       => $params->{wait},
        background => $params->{background}
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
                "[scheduler] $target->{id} is not ready yet, next server " .
                "contact planned for " . localtime($target->getNextRunDate())
            );
            return;
        }
    }

    if ($self->{wait}) {
        # return next target after waiting for a random delay
        my $time = int rand($self->{wait});
        $logger->info(
            "[scheduler] sleeping for $time second(s) because of the wait " .
            "parameter"
        );
        sleep $time;
        return $target;
    }

    # return next target immediatly
    return $target;
}

sub getTargets {
    my ($self) = @_;

    return @{$self->{targets}}
}

sub resetNextRunDate {
    my ($self) = @_;


    foreach my $target (@{$self->{targets}}) {
        $target->resetNextRunDate();
    }


}

1;
