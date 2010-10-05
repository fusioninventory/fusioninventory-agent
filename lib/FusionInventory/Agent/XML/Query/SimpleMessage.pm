package FusionInventory::Agent::XML::Query::SimpleMessage;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::TreePP;

sub new {
    my ($class, $params) = @_;

    die "no msg parameter" unless $params->{msg};

    my $self = $class->SUPER::new($params);

    foreach (keys %{$params->{msg}}) {
        $self->{h}{$_} = $params->{msg}{$_};
    }

    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::XML::Query::SimpleMessage - A generic message container

=head1 DESCRIPTION

This class provides a mechanism to send generic messages to the server.

    my $xmlMsg = FusionInventory::Agent::XML::Query::SimpleMessage->new({
        logger => $logger,
        deviceid => 'foo',
        msg => {
            QUERY => 'DOWNLOAD',
            FOO    => 'foo',
            BAR   => 'my Message',
        },
    });
    $network->send( { message => $xmlMsg }

The msg parameter only requires the QUERY key to identify the type of message.
You can use the key you want in the msg structure.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::XML::Query>, as keys of the
$params hashref:

=over

=item I<msg>

the msg content, as an hashref (mandatory)

=back
