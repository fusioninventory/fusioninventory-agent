package FusionInventory::Agent::Task;

use strict;
use warnings;

sub getPrologResponse {
    my ($self, %params) = @_;

    my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
        logger   => $self->{logger},
        deviceid => $params{deviceid},
        token    => $params{token}
    );

    if ($params{tag}) {
        $prolog->setAccountInfo(TAG => $params{tag});
    }

    return $params{transmitter}->send(
        message => $prolog,
        url     => $params{url}
    );
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Abstract task

=head1 DESCRIPTION

A task is a specific work to execute.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<target>

=item I<storage>

=item I<prologresp>

=back

=head2 run()

This is the method expected to be implemented by each subclass.
