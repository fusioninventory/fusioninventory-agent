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
        logger       => $params{logger} ||
                        FusionInventory::Agent::Logger->new(),
        maxDelay     => $params{maxDelay} || 3600,
        initialDelay => $params{delaytime},
        client       => $params{client},
        deviceid     => $params{deviceid},
        configValidityNextCheck => 0,
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

    $self->_saveState();

}

sub setShared {
    my ($self) = @_;

    $self->{shared} = 1;
}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub getEvents {
    my ($self) = @_;

    return $self->{events};
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
         "TODO";
}

# compute a run date, as current date and a random delay
# between maxDelay / 2 and maxDelay
sub _computeNextRunDate {
    my ($self) = @_;

    my $ret;
    if ($self->{initialDelay}) {
        $ret = time + $self->{initialDelay};
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

    $self->{maxDelay} = $data->{maxDelay} if $data->{maxDelay};
    $self->{events}   = $data->{events}   if $data->{events};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'target',
        data => {
            maxDelay => $self->{maxDelay},
            events   => $self->{events},
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
