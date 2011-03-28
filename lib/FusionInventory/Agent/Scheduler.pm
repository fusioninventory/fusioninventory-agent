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

sub getNext {
    my ($self) = @_;

    my $logger = $self->{'logger'};

    return unless @{$self->{targets}};

    if ($self->{background}) {
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                if (time > $target->getNextRunDate()) {
                    return $target;
                }
            }
            sleep(10);
        }
    } elsif ($self->{lazy} && @{$self->{targets}}) {
        my $target = shift @{$self->{targets}};
        if (time > $target->getNextRunDate()) {
            $logger->debug("Processing ".$target->{'path'});
            return $target;
        } else {
            $logger->info("Nothing to do for ".$target->{'path'}.
		". Next server contact planned for ".
                localtime($target->getNextRunDate())
		);
        }
    } elsif ($self->{wait}) {
        my $time = int rand($self->{wait});
        $logger->info("Going to sleep for $time second(s) because of the".
            " wait parameter");
        sleep($time);
        return shift @{$self->{targets}}
    } else {
        return shift @{$self->{targets}}
    }

    return;
}

sub numberOfTargets {
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
