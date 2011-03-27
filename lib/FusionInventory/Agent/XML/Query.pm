package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    die "no deviceid parameter" unless $params->{deviceid};

    my $self = {
        logger   => $params->{logger},
        deviceid => $params->{deviceid}
    };
    bless $self, $class;

    $self->{h} = {
        DEVICEID => [ $params->{deviceid} ]
    };

    if (
        $params->{currentDeviceid} &&
        ($params->{deviceid} ne $params->{currentDeviceid})
    ) {
      $self->{h}{OLD_DEVICEID} = [ $params->{currentDeviceid} ];
    }
  
    return $self;
}

sub getContent {
    my ($self, $args) = @_;

    my $content = XMLout(
        $self->{h},
        RootName      => 'REQUEST',
        XMLDecl       => '<?xml version="1.0" encoding="UTF-8"?>',
        SuppressEmpty => undef,
        NoAttr        => 1,
        KeyAttr       => []
    );

    return $content;
}


1;

__END__

=head1 NAME

FusionInventory::Agent::XML::Query - Base class for agent messages

=head1 DESCRIPTION

This is an abstract class for all XML query messages sent by the agent to the
server.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use

=item I<deviceid>

the agent identifier (mandatory)

=item I<currentDeviceid>

=back

=head2 getContent

Get XML content.
