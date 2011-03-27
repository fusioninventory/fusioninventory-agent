package FusionInventory::Agent::XML::Query::SimpleMessage;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    foreach (keys %{$params->{msg}}) {
        $self->{h}{$_} = $params->{msg}{$_};
    }

    my $logger = $self->{logger};
    my $target = $self->{target};

    $logger->fault("No msg") unless $params->{msg};

    return $self;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query::SimpleMessage - a Generic message container

=head1 DESCRIPTION

This class provides a mechanism to send generic messages to the server.

    my $xmlMsg = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        {
            config => $config,
            logger => $logger,
            target => $target,
            msg    => {
                QUERY => 'DOWNLOAD',
                FOO    => 'foo',
                BAR   => 'my Message',
            },
        }
    );
    $network->send( { message => $xmlMsg }

The msg parameter only requires the QUERY key to identify the type of message.
You can use the key you want in the msg structure.
