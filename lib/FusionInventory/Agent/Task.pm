package FusionInventory::Agent::Task;

use strict;
use warnings;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger      => $params->{logger},
        config      => $params->{config},
        target      => $params->{target},
        prologresp  => $params->{prologresp},
        transmitter => $params->{transmitter},
        setup       => $params->{setup},
        deviceid    => $params->{deviceid}
    };

    bless $self, $class;

    return $self;
}

sub main {
    my ($class) = @_;
    my $self = $class->new();
    $self->run();
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<config>

=item I<target>

=item I<storage>

=item I<prologresp>

=back

=head2 run()

This is the method expected to be implemented by each subclass.
