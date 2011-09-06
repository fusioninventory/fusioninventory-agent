package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;

sub new {
    my ($class, %params) = @_;

    die 'no basevardir parameter' unless $params{basevardir};

    my $self = {
        logger   => $params{logger} ||
                     FusionInventory::Agent::Logger->new(),
        maxDelay => $params{maxDelay} || 3600,
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

    $self->{nextRunDate} = _computeNextRunDate($self->{maxDelay})
        if !$self->{nextRunDate};

    $self->_saveState();

    $logger->debug(
        "[target $self->{id}] Next server contact planned for " .
        localtime($self->{nextRunDate})
    );

}

sub setShared {
    my ($self) = @_;

    # make sure relevant attributes are shared between threads
    threads::shared->require();
    threads::shared::share($self->{nextRunDate});

    $self->{shared} = 1;

}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    lock($self->{nextRunDate}) if $self->{shared};
    $self->{nextRunDate} = $nextRunDate;
    $self->_saveState();
}

sub resetNextRunDate {
    my ($self) = @_;

    lock($self->{nextRunDate}) if $self->{shared};
    $self->{nextRunDate} = _computeNextRunDate($self->{maxDelay});
    $self->_saveState();
}

sub getNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate};
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

sub getStatus {
    my ($self) = @_;

    return
        $self->getDescription() .
        ': '                    .
         ($self->{nextRunDate} > 1 ? localtime($self->{nextRunDate}) : "now" );
}

# compute a run date, as current date and a random delay
# between maxDelay / 2 and maxDelay
sub _computeNextRunDate {
    my ($maxDelay) = @_;

    return
        time                   +
        $maxDelay / 2          +
        int rand($maxDelay / 2);
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'target');

    $self->{maxDelay}    = $data->{maxDelay}    if $data->{maxDelay};
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'target',
        data => {
            maxDelay    => $self->{maxDelay},
            nextRunDate => $self->{nextRunDate},
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

=head2 setShared()

Ensure the target can be shared among threads

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set next execution date.

=head2 resetNextRunDate()

Set next execution date to a random value.

=head2 getMaxDelay($maxDelay)

Get maxDelay attribute.

=head2 setMaxDelay($maxDelay)

Set maxDelay attribute.

=head2 getStorage()

Return the storage object for this target.

=head2 getDescription()

Return a string description of the target.

=head2 getStatus()

Return a string status for the target.
