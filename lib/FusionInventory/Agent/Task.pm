package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    die 'no target parameter' unless $params->{target};

    my $self = {
        logger      => $params->{logger},
        config      => $params->{config},
        target      => $params->{target},
        prologresp  => $params->{prologresp},
        network     => $params->{network},
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

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<config>

=item I<target>

=item I<storage>

=item I<prologresp>

=item I<network>

=item I<deviceid>

=back

=head2 main()

This is the method to be implemented by each subclass.
