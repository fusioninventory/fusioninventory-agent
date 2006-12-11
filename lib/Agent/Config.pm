package Ocsinventory::Agent::Config;
use strict;
use warnings;

use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
print Dumper($self->{params});

  # Configuration reading
  $self->{xml} = XML::Simple::XMLin($self->{params}->{etcdir}."/ocsinv.conf",
    SuppressEmpty => undef);

  bless $self;
}

sub get {
  my ($self, $name) = @_;

  return $self->{xml}->{$name} if $name;
  return $self->{xml};
}

sub set {
  my ($self, $name, $value) = @_;

  $self->{xml}->{$name} = $value;
}


sub write {
  my ($self, $args) = @_;

}

1;
