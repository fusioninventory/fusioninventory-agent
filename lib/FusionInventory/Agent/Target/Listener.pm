package FusionInventory::Agent::Target::Listener;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Target';

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->_init(
        id     => 'listener',
        vardir => $params{basevardir} . '/__LISTENER__',
    );

    return $self;
}

sub getName {
    return 'listener';
}

sub getType {
    return 'listener';
}

# No task planned as the only purpose is to answer HTTP API
sub plannedTasks {
    return ();
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Listen - Listen target

=head1 DESCRIPTION

This is a target to serve execution result on a listening port.

=head1 METHODS

=head2 new(%params)

The constructor. The allowed parameters are the ones from the base class
C<FusionInventory::Agent::Target>.

=head2 getName()

Return the target name

=head2 getType()

Return the target type

=head2 plannedTasks([@tasks])

Initializes target tasks with supported ones if a list of tasks is provided

Return an array of planned tasks.
