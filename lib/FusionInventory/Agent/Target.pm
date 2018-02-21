package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;

sub new {
    my ($class, %params) = @_;

    die "no basevardir parameter for target\n" unless $params{basevardir};

    my $self = {
        logger       => $params{logger} ||
                        FusionInventory::Agent::Logger->new(),
        maxDelay     => $params{maxDelay} || 3600,
        initialDelay => $params{delaytime},
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, %params) = @_;

    my $logger = $self->{logger};

    # target identity
    $self->{id} = $params{id};

    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $self->{logger},
        directory => $params{vardir}
    );

    # handle persistent state
    $self->_loadState();

    $self->{nextRunDate} = $self->_computeNextRunDate()
        if (!$self->{nextRunDate} || $self->{nextRunDate} < time-$self->getMaxDelay());

    $self->_saveState();

    $logger->debug(
        "[target $self->{id}] Next server contact planned for " .
        localtime($self->{nextRunDate})
    );

}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    $self->{nextRunDate} = $nextRunDate;
    $self->_saveState();
}

sub registerInternalEvent {
    my ($self, $delay, $task, $event) = @_;

    # We accept null delay
    return unless defined($delay) && $task && $event;

    if ($delay) {
        push @{$self->{nextInternalEvents}}, [ time() + $delay, $task, $event ];
        $self->{logger}->debug2(
            "[target $self->{id}] Registered $event event for $task in $delay second(s)"
        ) if $self->{logger};
    } else {
        # Filter task internal event from list while delay is null
        my @events = grep {
            $_->[1] ne $task || $_->[2] ne $event
        } @{$self->{nextInternalEvents}};
        $self->{nextInternalEvents} = \@events;
        $self->{logger}->debug2(
            "[target $self->{id}] Unregistered $event event for $task"
        ) if $self->{logger};
    }

    # Always sort by time to keep next event as first event
    # We also prefer to avoid any duplicated event and reschedule the event
    if (@{$self->{nextInternalEvents}} > 1) {
        my @events = ();
        my %uniqtaskevents = ();
        foreach my $other (@{$self->{nextInternalEvents}}) {
            if ($other->[1] eq $task) {
                $uniqtaskevents{$other->[2]} = $other->[0];
            } else {
                push @events, $other;
            }
        }
        # Be sure here to re-schedule this event
        $uniqtaskevents{$event} = time() + $delay;
        push @events, map { [ $uniqtaskevents{$_}, $task, $_ ] } keys(%uniqtaskevents);
        my @sorted_events = sort { $a->[0] <=> $b->[0] } @events;
        $self->{nextInternalEvents} = \@sorted_events;
    }
    $self->_saveState();
}

sub setNextRunDateFromNow {
    my ($self, $nextRunDelay) = @_;

    if ($nextRunDelay) {
        # While using nextRunDelay, we double it on each consecutive call until
        # delay reach target defined maxDelay. This is only used on network failure.
        $nextRunDelay = 2 * $self->{_nextrundelay} if ($self->{_nextrundelay});
        $nextRunDelay = $self->getMaxDelay() if ($nextRunDelay > $self->getMaxDelay());
        $self->{_nextrundelay} = $nextRunDelay;
    }
    $self->{nextRunDate} = time + ($nextRunDelay || 0);
    $self->_saveState();
}

sub resetNextRunDate {
    my ($self) = @_;

    $self->{_nextrundelay} = 0;
    $self->{nextRunDate} = $self->_computeNextRunDate();
    $self->_saveState();
}

sub getNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate};
}

sub getNextExpiredInternalEvent {
    my ($self) = @_;

    return unless $self->{nextInternalEvents};

    return unless ref($self->{nextInternalEvents}) eq 'ARRAY';

    return unless @{$self->{nextInternalEvents}} > 0;

    # Just remove next event if not conform
    my ($expiration, $task, $event);
    while (@{$self->{nextInternalEvents}}) {
        ($expiration, $task, $event) = @{$self->{nextInternalEvents}->[0]};
        last if defined($expiration) && $task && $event;
        shift @{$self->{nextInternalEvents}};
    }
    return unless defined($expiration) && $task && $event;

    return if (scalar(time()) < $expiration);

    shift @{$self->{nextInternalEvents}};

    $self->_saveState();

    return ($task , $event);
}

sub paused {
    my ($self) = @_;

    return $self->{_paused} || 0;
}

sub pause {
    my ($self) = @_;

    $self->{_paused} = 1;
}

sub continue {
    my ($self) = @_;

    delete $self->{_paused};
}

sub getFormatedNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate} > 1 ?
        scalar localtime($self->{nextRunDate}) : "now";
}

sub getMaxDelay {
    my ($self) = @_;

    return $self->{maxDelay};
}

sub setMaxDelay {
    my ($self, $maxDelay) = @_;

    $self->{maxDelay} = $maxDelay;
    $self->_saveState();
}

sub isType {
    my ($self, $testtype) = @_;

    return unless $testtype;

    my $type = $self->getType()
        or return;

    return "$type" eq "$testtype";
}

# compute a run date, as current date and a random delay
# between maxDelay / 2 and maxDelay
sub _computeNextRunDate {
    my ($self) = @_;

    my $ret;
    if ($self->{initialDelay}) {
        $ret = time + ($self->{initialDelay} / 2) + int rand($self->{initialDelay} / 2);
        $self->{initialDelay} = undef;
    } else {
        $ret =
            time                   +
            $self->{maxDelay} / 2  +
            int rand($self->{maxDelay} / 2);
    }

    return $ret;
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'target');

    $self->{maxDelay}    = $data->{maxDelay}    if $data->{maxDelay};
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};

    $self->{nextInternalEvents} = $data->{nextInternalEvents} || [];
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'target',
        data => {
            maxDelay    => $self->{maxDelay},
            nextRunDate => $self->{nextRunDate},

            nextInternalEvents  => $self->{nextInternalEvents},
        }
    );
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<maxDelay>

the maximum delay before contacting the target, in seconds
(default: 3600)

=item I<basevardir>

the base directory of the storage area (mandatory)

=back

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 getFormatedNextRunDate()

Get nextRunDate attribute as a formated string.

=head2 setNextRunDate($nextRunDate)

Set next execution date.

=head2 setNextRunDateFromNow($nextRunDelay)

Set next execution date from now and after $nextRunDelay seconds (0 by default).

=head2 resetNextRunDate()

Set next execution date to a random value.

=head2 getMaxDelay($maxDelay)

Get maxDelay attribute.

=head2 setMaxDelay($maxDelay)

Set maxDelay attribute.

=head2 getStorage()

Return the storage object for this target.
