package Ocsinventory::Logger;

use Carp;
sub new {

  my (undef, $params) = @_;

  my $self = {};
  $self->{backend} = [];
  $self->{params} = $params->{params};

  print Dumper($params);
  print "->".$self->{params}->{logger}."\n";
  my @logger = split /,/, $self->{params}->{logger};

  use Data::Dumper;

  foreach (@logger) {
    my $backend = "Ocsinventory::LoggerBackend::".$_; 
    eval ("require $backend"); # TODO deal with error
    my $obj = new $backend;
    push @{$self->{backend}}, $obj if $obj;
  }

  bless $self;
}

sub log {
  my ($self, $args) = @_;

  # levels: info, debug, warn, fault
  my $level = $args->{level};
  my $message = $args->{message};
  
  chomp($message);
  $level = 'info' unless $level;

  foreach (@{$self->{backend}}) {
    $_->addMsg ({
      level => $level,
      message => $message
    });
  }
  confess if $level =~ /^fault$/; # Die with a backtace 
}

1;
