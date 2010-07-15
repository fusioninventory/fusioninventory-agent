package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use Carp;
use XML::TreePP;

sub new {
    my ($class, $params) = @_;

    croak "No DEVICEID" unless $params->{target}->{deviceid};

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
