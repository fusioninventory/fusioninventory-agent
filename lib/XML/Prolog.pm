package Ocsinventory::XML::Prolog;

use strict;
use warnings;

use Data::Dumper; # XXX Debug
use XML::Simple;
use Digest::MD5 qw(md5_base64);

sub new {
  my (undef,$params) = @_;

  my $self = {};
  $self->{params} = $params->{params};
 
  die unless ($self->{params}->{deviceid}); #XXX

  $self->{h}{QUERY} = ['PROLOG']; 
  $self->{h}{DEVICEID} = [$self->{params}->{deviceid}]; 

  bless $self;
}

sub dump {
  my $self = shift;
  print Dumper($self->{h});

}

sub content {
  my ($self, $args) = @_;

  my $content=XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="ISO-8859-1"?>',
    NoSort => 1, SuppressEmpty => undef );

  return $content;
}

1;
