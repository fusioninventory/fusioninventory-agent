package FusionInventory::LoggerBackend::Stderr;

use strict;
use warnings;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{config} = $params->{config};
  bless $self;
}

sub addMsg {

  my ($self, $args) = @_;

  my $config = $self->{config};

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;
  
  # if STDERR has been hijacked, I take its saved ref
  my $stderr;
  if (exists ($self->{config}->{savedstderr})) {
    $stderr = $self->{config}->{savedstderr};
  } else {
    open ($stderr, ">&STDERR");
  }


  if ($config->{color}) {
    if ($level eq 'error') {
      print $stderr  "\033[1;35m[$level]";
    } elsif ($level eq 'fault') {
      print $stderr  "\033[1;31m[$level]";
    } elsif ($level eq 'info') {
      print $stderr  "\033[1;34m[$level]\033[0m";
    } elsif ($level eq 'debug') {
      print $stderr  "\033[1;1m[$level]\033[0m";
    }
    print $stderr  " $message";
    print "\033[0m\n";
  } else {
    print $stderr "[$level] $message\n";
  }

}

1;
