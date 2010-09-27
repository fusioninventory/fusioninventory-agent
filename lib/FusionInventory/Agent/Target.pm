package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Path qw(make_path);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, $params) = @_;

    my $self = {
        maxOffset       => $params->{maxOffset} || 3600,
        logger          => $params->{logger},
        path            => $params->{path} || '',
        deviceid        => $params->{deviceid},
        nextRunDate     => undef,
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, $params) = @_;
    my $logger = $self->{logger};

    # target identity
    $self->{id} = $params->{id};

    # target storage directory
    $self->{vardir} = $params->{vardir};

    if (!-d $self->{vardir}) {
        make_path($self->{vardir}, {error => \my $err});
        if (@$err) {
            $logger->error("Failed to create $self->{vardir}");
        }
    }

    if (! -w $self->{vardir}) {
        die "Can't write in $self->{vardir}";
    }

    $logger->debug("[target $self->{id}] Storage directory: $self->{vardir}");

    # restore previous state
    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });
    $self->_load();

    # initialize next run date
    $self->scheduleNextRun();
}

sub getNextRunDate {
    my ($self) = @_;

    return $self->{nextRunDate};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    return if $self->_isSameScalar($nextRunDate, $self->{nextRunDate});

    $self->{nextRunDate} = $nextRunDate;
    $self->_save();
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

    return if $self->_isSameScalar($maxOffset, $self->{maxOffset});

    $self->{maxOffset} = $maxOffset;
    $self->_save();
}

sub _load {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{maxOffset}   = $data->{maxOffset} if $data->{maxOffset};

    if ($self->{nextRunDate}) {
        $self->{logger}->debug (
            "[target $self->{id}] Next server contact planned for ".
            localtime($data->{nextRunDate})
        );
    }

    return $data;
}

sub _save {
    my ($self, $data) = @_;

    $data->{nextRunDate} = $self->{nextRunDate};
    $data->{maxOffset}   = $self->{maxOffset};
    $self->{storage}->save({ data => $data });
}

sub _isSameScalar {
    my ($self, $value1, $value2) = @_;

    return if ! defined $value1; 
    return if ! defined $value2;

    return $value1 eq $value2;
}

sub _isSameHash {
    my ($self, $value1, $value2) = @_;

    return if ! defined $value1; 
    return if ! defined $value2;

    my $dump1 = join(',', map { "$_=$value1->{$_}" } sort keys %$value1);
    my $dump2 = join(',', map { "$_=$value2->{$_}" } sort keys %$value2);

    return $dump1 eq $dump2;
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

=item path: filesystem path or server url

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
