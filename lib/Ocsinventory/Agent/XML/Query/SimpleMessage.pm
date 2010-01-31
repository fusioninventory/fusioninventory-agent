package Ocsinventory::Agent::XML::Query::SimpleMessage;

use strict;
use warnings;

use XML::Simple;
use Ocsinventory::Agent::XML::Query;

our @ISA = ('Ocsinventory::Agent::XML::Query');

sub new {
  my ($class, $params) = @_;

  my $self = $class->SUPER::new($params);
  bless ($self, $class);

  $self->{h} = $params->{msg};

  my $logger = $self->{logger};

  $logger->fault("No msg") unless $params->{msg};

  if (!$self->{config}->{deviceid}) {
    $logger->fault("No device ID found in the config");
  }
  $self->{h}{DEVICEID} = $self->{config}->{deviceid};

  return $self;
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
