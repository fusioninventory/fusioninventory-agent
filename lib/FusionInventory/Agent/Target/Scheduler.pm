package FusionInventory::Agent::Target::Scheduler;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);
use URI;

my $count = 0;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{storage} = $params{storage};
    $self->{name}    = 'scheduler' . $count++,

    # handle persistent state
    $self->_loadState();

    $self->{nextRunDate} = $self->_computeNextRunDate()
        if (!$self->{nextRunDate} || $self->{nextRunDate} < time-$self->getMaxDelay());

    $self->_saveState();

    return $self;
}

sub getName {
    my ($self) = @_;

    return $self->{name};
}

sub getType {
    my ($self) = @_;

    return 'scheduler';
}

sub plannedTasks {
    my $self = shift @_;

    # Keep only Maintenance as local task
    if (@_) {
        $self->{tasks} = [ grep { $_ =~ /^Maintenance$/i } @_ ];
    }

    return @{$self->{tasks} || []};
}

sub _loadState {
    my ($self) = @_;

    my $data = $self->{storage}->restore(name => 'scheduler');

    $self->{maxDelay}    = $data->{maxDelay}    if $data->{maxDelay};
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(
        name => 'scheduler',
        data => {
            maxDelay    => $self->{maxDelay},
            nextRunDate => $self->{nextRunDate},
        }
    );
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Scheduler - Scheduler target

=head1 DESCRIPTION

This is a target to schedule some local agent maintenance.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::Target>, as keys of the %params
hash:

=over

=item I<url>

the server URL (mandatory)

=back

=head2 getUrl()

Return the server URL for this target.
