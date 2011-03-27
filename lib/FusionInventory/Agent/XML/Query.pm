package FusionInventory::Agent::XML::Query;

use strict;
use warnings;

use XML::Simple;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config => $params->{config},
        logger => $params->{logger},
        target => $params->{target}
    };
    bless $self, $class;

    my $target = $self->{target};

    $self->{h} = {
        QUERY    => [ 'UNSET!' ],
        DEVICEID => [ $target->{deviceid} ]
    };

    if (
        $target->{currentDeviceid} &&
        ($target->{deviceid} ne $target->{currentDeviceid})
    ) {
      $self->{h}{OLD_DEVICEID} = [ $target->{currentDeviceid} ];
    }
  
    $self->{logger}->fault("No DEVICEID") unless $target->{deviceid};

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
