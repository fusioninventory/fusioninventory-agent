package FusionInventory::Agent::Task;

use strict;
use warnings;

use FusionInventory::Logger;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config      => $params->{config},
        target      => $params->{target},
        logger      => $params->{logger} || FusionInventory::Logger->new(),
        prologresp  => $params->{prologresp},
        transmitter => $params->{transmitter},
        deviceid    => $params->{deviceid}
    };

    bless $self, $class;

    return $self;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item config (mandatory)

=item target (mandatory)

=item logger: the logger object to use

=item storage (mandatory)

=item prologresp (mandatory)

=back

=head2 run()

This is the method expected to be implemented by each subclass.
