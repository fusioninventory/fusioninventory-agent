package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use Carp;
use XML::TreePP;

sub new {
    my ($class, $params) = @_;

    # Q: Why should we use die instead of $logger->fault() ?
    die "No DEVICEID" unless $params->{target}->{deviceid};

    my $self = {
        accountinfo => $params->{accountinfo},
        logger      => $params->{logger},
        target      => $params->{target},
        storage     => $params->{storage}
    };
    bless $self, $class;

    my $target = $self->{target};

    $self->{h} = {
        QUERY    => ['UNSET!'],
        DEVICEID => [$target->{deviceid}]
    };

    if (
        $target->{currentDeviceid} &&
        $target->{deviceid} ne $target->{currentDeviceid}
    ) {
      $self->{h}->{OLD_DEVICEID} = [$target->{currentDeviceid}];
    }

    return $self;
}

sub getContent {
    my ($self, $args) = @_;

    my $tpp = XML::TreePP->new();
    my $content = $tpp->write( { REQUEST => $self->{h} } );

    return $content;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query - Base class for query message

=head1 DESCRIPTION

This is an abstract class for all XML query messages sent by the agent to the
server.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item accountinfo (mandatory)

=item logger (mandatory)

=item target (mandatory)

=back

=head2 getContent

Get XML content.
