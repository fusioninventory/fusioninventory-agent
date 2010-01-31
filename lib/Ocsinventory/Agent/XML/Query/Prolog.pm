package Ocsinventory::Agent::XML::Query::Prolog;

use strict;
use warnings;

use XML::Simple;
use Digest::MD5 qw(md5_base64);
use Ocsinventory::Agent::XML::Query;

our @ISA = ('Ocsinventory::Agent::XML::Query');
#use Ocsinventory::Agent::XML::Query::Prolog;

sub new {
  my ($class, $params) = @_;

  my $self = $class->SUPER::new($params);
  bless ($self, $class);

  my $logger = $params->{logger};
  my $rpc = $params->{rpc};

  $logger->fault("No DEVICEID") unless ($self->{config}->{deviceid});

  $self->{h}{QUERY} = ['PROLOG'];
  $self->{h}{DEVICEID} = [$self->{config}->{deviceid}];
  $self->{h}{TOKEN} = [$rpc->getToken()];

  return $self;
}

sub dump {
  my $self = shift;
  eval "use Data::Dumper;";
  print Dumper($self->{h});

}

sub getContent {
  my ($self, $args) = @_;

  $self->{accountinfo}->setAccountInfo($self);
  my $content=XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>',
    SuppressEmpty => undef );

  return $content;
}



1;
