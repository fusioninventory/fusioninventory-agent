package Ocsinventory::Agent::XML::Prolog;

use strict;
use warnings;

use XML::Simple;
use Digest::MD5 qw(md5_base64);

#use Ocsinventory::Agent::XML::Prolog;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{config} = $params->{config};
  $self->{accountinfo} = $params->{accountinfo};

  die unless ($self->{config}->{deviceid}); #XXX

  $self->{h}{QUERY} = ['PROLOG'];
  $self->{h}{DEVICEID} = [$self->{config}->{deviceid}];

  bless $self;
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
