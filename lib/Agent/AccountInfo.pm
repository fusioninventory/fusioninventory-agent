package Ocsinventory::Agent::AccountInfo;

use strict;
use warnings;

use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
  $self->{logger} = $params->{logger};

  my $xmladm = XML::Simple::XMLin($self->{params}->{etcdir}."/ocsinv.adm", ForceArray =>
    [ 'ACCOUNTINFO' ] );

  for(@{$xmladm->{ACCOUNTINFO}}){
    $self->{accountinfo}{ $_->{KEYNAME} } = $_->{KEYVALUE};
  }

  bless $self;
}

sub get {
  my ($self, $name) = @_;

  return $self->{accountinfo} if $name;
  return $self->{accountinfo};
}

sub set {
  my ($self, $name, $value) = @_;

  $self->{accountinfo}->{$name} = $value;
}


sub write {
  my ($self, $args) = @_;
  my $tmp;
  $tmp->{ACCOUNTINFO} = [];

  foreach (keys %{$self->{accountinfo}}) {
    push @{$tmp->{ACCOUNTINFO}}, {KEYNAME => [$_], KEYVALUE =>
      [$self->{accountinfo}{$_}]}; 
  }
  
  my $xml=XML::Simple::XMLout( $tmp, RootName => 'ADM',
    NoSort => 1 );

  print localtime()." =>
  Updating Account infos\n";

  open ADM, ">".$self->{params}{cfgpath}."/ocsinv.adm";
  print ADM $xml;
  close ADM;
}

1;
