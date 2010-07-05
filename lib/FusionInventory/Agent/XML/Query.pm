package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use Carp;
use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config      => $params->{config},
        accountinfo => $params->{accountinfo},
        logger      => $params->{logger},
        target      => $params->{target}
    };
    bless $self, $class;

    my $rpc = $self->{rpc};
    my $target = $self->{target};
    my $logger = $self->{logger};

    $self->{h} = {};
    $self->{h}{QUERY} = ['UNSET!'];
    $self->{h}{DEVICEID} = [$target->{deviceid}];

    if ($target->{currentDeviceid} && ($target->{deviceid} ne $target->{currentDeviceid})) {
      $self->{h}{OLD_DEVICEID} = [$target->{currentDeviceid}];
    }
  
    croak "No DEVICEID" unless $target->{deviceid};

    return $self;
}


1;
