package FusionInventory::Agent::XML::Query::SimpleMessage;

use strict;
use warnings;

use XML::Simple;
use FusionInventory::Agent::XML::Query;

our @ISA = ('FusionInventory::Agent::XML::Query');

sub new {
  my ($class, $params) = @_;

  my $self = $class->SUPER::new($params);
  bless ($self, $class);

  foreach (keys %{$params->{msg}}) {
    $self->{h}{$_} = $params->{msg}{$_};
  }

  my $logger = $self->{logger};
  my $target = $self->{target};

  $logger->fault("No msg") unless $params->{msg};

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
