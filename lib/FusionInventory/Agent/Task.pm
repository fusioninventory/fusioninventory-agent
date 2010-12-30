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

The constructor. See subclass documentation for parameters.

=head2 run(%params)

Run the task. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<target>

=item I<confdir>

=item I<datadir>

=item I<deviceid>

=item I<token>

=back

=head2 getPrologResponse(%params)

Establish preliminary dialog with a server target, and returns server response.

The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<deviceid>

=item I<token>

=item I<url>

=item I<tag>

=back
