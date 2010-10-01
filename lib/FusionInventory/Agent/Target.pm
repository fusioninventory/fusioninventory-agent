package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, $params) = @_;

    my $self = {
        maxOffset       => $params->{maxOffset} || 3600,
        logger          => $params->{logger},
        nextRunDate     => undef,
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, $params) = @_;

    # target identity
    $self->{id} = $params->{id};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new({
        logger    => $self->{logger},
        directory => $params->{vardir}
    });

    # restore previous state
    $self->_loadState();

    # initialize next run date
    $self->scheduleNextRun();
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
    $self->saveState();
}

sub scheduleNextRun {
    my ($self, $offset) = @_;

    if (! defined $offset) {
        $offset = ($self->{maxOffset} / 2) + int rand($self->{maxOffset} / 2);
    }
    my $time = time() + $offset;
    $self->setNextRunDate($time);

    $self->{logger}->debug(
        "[target $self->{id}]" . 
        defined $offset ?
            "Next run scheduled for " . localtime($time + $offset) :
            "Next run forced now"
    );

}

sub getMaxOffset {
    my ($self) = @_;

    return $self->{maxOffset};
}

sub setMaxOffset {
    my ($self, $maxOffset) = @_;

    $self->{maxOffset} = $maxOffset;
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{maxOffset}   = $data->{maxOffset} if $data->{maxOffset};
}

sub saveState {
    my ($self) = @_;

    $self->{storage}->save({
        data => {
            nextRunDate => $self->{nextRunDate},
            maxOffset   => $self->{maxOffset},
        }
    });
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item maxOffset: maximum delay in seconds (default: 3600)

=item logger: logger object to use (mandatory)

=item deviceid: 

=item nextRunDate: 

=back

=head2 getMaxOffset()

Get maxOffset attribute.

=head2 setMaxOffset($maxOffset)

Set maxOffset attribute.

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set nextRunDate attribute.

=head2 scheduleNextRun($offset)

Re-schedule the target to current time + given offset. If offset is not given,
it's computed randomly as: (maxOffset / 2) + rand(maxOffset / 2)

=head2 getStorage()

Return the storage object for this target.

=head2 saveState()

Save persistant part of current state.
