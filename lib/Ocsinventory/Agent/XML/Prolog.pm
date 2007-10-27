package Ocsinventory::Agent::XML::Prolog;

use strict;
use warnings;

use Data::Dumper; # XXX Debug
use XML::Simple;
use Digest::MD5 qw(md5_base64);

use Ocsinventory::Agent::XML::Prolog;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{params} = $params->{params};
  $self->{accountinfo} = $params->{accountinfo};
 
  die unless ($self->{params}->{deviceid}); #XXX

  $self->{h}{QUERY} = ['PROLOG']; 
  $self->{h}{DEVICEID} = [$self->{params}->{deviceid}];
#  $self->{h}{ACCOUNTINFO} = $self->{accountinfo}->{}; 

  bless $self;
}

sub dump {
  my $self = shift;
  print Dumper($self->{h});

}

sub getContent {
  my ($self, $args) = @_;

  $self->{accountinfo}->setAccountInfo($self);
  my $content=XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="ISO-8859-1"?>',
    SuppressEmpty => undef );

  return $content;
}



1;
