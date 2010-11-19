package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, $params) = @_;

    die 'no basevardir parameter' unless $params->{basevardir};

    my $self = {
        maxOffset       => $params->{maxOffset} || 3600,
        logger          => $params->{logger},
        deviceid        => $params->{deviceid},
        format          => $params->{format},
        nextRunDate     => undef,
    };

    bless $self, $class;
    
    return $self;
}

sub _init {
    my ($self, $params) = @_;

    # target identity
    $self->{id} = $params->{id};
    $self->{vardir} = $params->{vardir};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new({
        logger    => $self->{logger},
        directory => $self->{vardir}
    });

    # restore previous state
    $self->_loadState();

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

sub getStatusString {
    my ($self, $params) = @_;

    my $string = '';
    if ($self->{modulenameRunning}) {
	$string .= "running module ".$self->{modulenameRunning};
    } else {
	$string .= "waiting";
    }

    my $cpt = @{$self->{modulenamesToRun}};
    if ($cpt) {
	$string .= " module run queue: ";
	foreach(0..$cpt) {
	    $string .= " ".$self->{modulenamesToRun}[$cpt];
	    $string .= "," if $cpt;
	}
    }

    return $string;
}



1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<maxOffset>

the maximum delay in seconds when rescheduling the target randomly
(default: 3600)

=item I<nextRunDate>

the next execution date, as a unix timestamp

=item I<basevardir>

the base directory of the storage area (mandatory)

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

=head2 run()

Run the tasks (inventory, snmp scan, etc) on the target

=head2 getDescriptionString()

Return a string to display to user in a 'target' field.

