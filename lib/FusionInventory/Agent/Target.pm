package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, %params) = @_;

    die 'no basevardir parameter' unless $params{basevardir};
    die 'no id parameter' unless $params{id};

    my $self = {
        id          => $params{id},
        period      => $params{period} || 3600,
        logger      => $params{logger},
        format      => $params{format},
    };

    bless $self, $class;

    # target-specific storage object
    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $self->{logger},
        directory => $params{basevardir} . '/' . $params{id}
    );

    # restore previous state
    $self->_loadState();

    # initialize next execution date if needed
    $self->scheduleNextRun() if !$self->{nextRunDate};
    
    return $self;
}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub getNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    $self->{nextRunDate} = $nextRunDate;
}

sub scheduleNextRun {
    my ($self, $offset) = @_;

    if (! defined $offset) {
        $offset = ($self->{period} / 2) + int rand($self->{period} / 2);
    }
    my $time = time() + $offset;
    $self->setNextRunDate($time);

    $self->{logger}->debug(
        "[target $self->{id}] Next run scheduled for " . localtime($time)
    );

}

sub getFormat {
    my ($self) = @_;

    return $self->{format};
}

sub getPeriod {
    my ($self) = @_;

    return $self->{period};
}

sub setPeriod {
    my ($self, $period) = @_;

    $self->{period} = $period;
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{period}      = $data->{period} if $data->{period};
}

sub saveState {
    my ($self) = @_;

    $self->{storage}->save(
        data => {
            nextRunDate => $self->{nextRunDate},
            period      => $self->{period},
        }
    );
}

sub getDescription {
    my ($self) = @_;

    my $description = {
        id     => $self->{id},
        period => $self->{period},
        time   =>
            $self->{nextRunDate} ? localtime($self->{nextRunDate}) : 'now',
        status =>
            $self->{nextRunDate} ? 'waiting' : 'running'
    };

    return $description;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

A target is the recipient of a task execution.

All target objects have the following attributes:

=over

=item I<id>

The target identifier.

=item I<period>

The approximative amount of time between two executions.

=item I<nextRunDate>

The exact time for next execution.

=item I<storage>

The C<FusionInventory::Agent::Storage> object used store content specific to
this target.

=item I<format>

The output format.

=back

See subclass-specific documention for additional attributes.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<period>

the target periodicity, in seconds (default: 3600)

=item I<nextRunDate>

the next execution date, as a unix timestamp

=item I<basevardir>

the base directory of the storage area (mandatory)

=back

=head2 getPeriod()

Get period attribute.

=head2 setPeriod($period)

Set period attribute.

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set nextRunDate attribute.

=head2 scheduleNextRun($offset)

Re-schedule the target to current time + given offset. If offset is not given,
it's computed randomly as: (period / 2) + rand(period / 2)

=head2 getStorage()

Return the storage object for this target.

=head2 saveState()

Save persistant part of current state.

=head2 run()

Run the tasks (inventory, snmp scan, etc) on the target

=head2 getDescriptionString()

Return a string to display to user in a 'target' field.

