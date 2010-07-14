package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use Carp;
use XML::Simple;

sub new {
    my ($class, $params) = @_;

    croak "No DEVICEID" unless $params->{target}->{deviceid};

    my $self = {
        config      => $params->{config},
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


1;
