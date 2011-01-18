package FusionInventory::Agent::Job;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, %params) = @_;

    die 'no id parameter'         unless $params{id};
    die 'no task parameter'       unless $params{task};
    die 'no target parameter'     unless $params{target};
    die 'no basevardir parameter' unless $params{basevardir};

    my $self = {
        id     => $params{id},
        task   => $params{task},
        target => $params{target},
        period => $params{period} || 3600,
        logger => $params{logger} || FusionInventory::Agent::Logger->new(),
        dirty  => 1
    };

    bless $self, $class;

    # create storage object
    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $self->{logger},
        directory => $params{basevardir} . '/' . $params{id}
    );

    # restore previous state if it exists
    $self->_loadState();

    # initialize next execution date if needed
    my $time = time();
    if (
        !$self->{nextRunDate}        || # no date yet
        $self->{nextRunDate} < $time    # date in the paste
    ) {
        $self->{nextRunDate} = $time + $self->_getOffset();
        $self->{dirty} = 1;
    }

    # save new state if needed
    $self->saveState() if $self->{dirty};

    $self->{logger}->debug(
        "[job $self->{id}] job created, next run scheduled for " .
        localtime($self->{nextRunDate})
    );
    
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
        $offset = $self->_getOffset();
    }
    my $time = time() + $offset;
    $self->setNextRunDate($time);

    $self->{logger}->debug(
        "[job $self->{id}] next run scheduled for " . localtime($time)
    );
}

sub getId {
    my ($self) = @_;
    return $self->{id};
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
    $self->{dirty} = 0;
}

sub saveState {
    my ($self) = @_;

    $self->{storage}->save(
        data => {
            nextRunDate => $self->{nextRunDate},
            period      => $self->{period},
        }
    );
    $self->{dirty} = 0;
}

sub _getOffset {
    my ($self) = @_;

    return ($self->{period} / 2) + int rand($self->{period} / 2);
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Job - Agent job

=head1 DESCRIPTION

A job is the combination of a target and a task

A job object has the following attributes:

=over

=item I<id>

The job identifier.

=item I<task>

The identifier of the task associated with this job.

=item I<target>

The identifier of the target associated with this job.

=item I<period>

The approximative amount of time between two executions.

=item I<nextRunDate>

The exact time for next execution.

=item I<storage>

The C<FusionInventory::Agent::Storage> object used store content specific to
this job.

=back

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<id>

the identifier for this job (mandatory).

=item I<task>

the task for this job (mandatory).

=item I<target>

the target for this job (mandatory).

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<period>

the job periodicity, in seconds (default: 3600)

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

Re-schedule the job to current time + given offset. If offset is not given,
it's computed randomly as: (period / 2) + rand(period / 2)

=head2 getStorage()

Return the storage object for this job.

=head2 saveState()

Save persistant part of current state.
