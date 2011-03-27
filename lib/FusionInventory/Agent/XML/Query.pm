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
        QUERY    => [ 'UNSET!' ],
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
