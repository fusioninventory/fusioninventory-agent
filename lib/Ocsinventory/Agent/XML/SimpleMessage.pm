package Ocsinventory::Agent::XML::SimpleMessage;

use strict;
use warnings;

use XML::Simple;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{config} = $params->{config};
  $self->{h} = $params->{msg};

  my $logger = $self->{logger} = $params->{logger};

  $logger->fault("No msg") unless $params->{msg};

  if (!$self->{config}->{deviceid}) {
    $logger->fault("No device ID found in the config");
  }
  $self->{h}{DEVICEID} = $self->{config}->{deviceid};

  bless $self;
}

sub dump {
  my $self = shift;
  print Dumper($self->{h});

}


sub getContent {
  my ($self, $args) = @_;

  my $content=XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>',
    SuppressEmpty => undef );

  return $content;
}



1;
