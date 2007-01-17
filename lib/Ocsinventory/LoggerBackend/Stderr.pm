package Ocsinventory::LoggerBackend::Stderr;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  print STDERR "[$level] $message\n";
}

1;
