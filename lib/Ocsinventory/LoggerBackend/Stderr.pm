package Ocsinventory::LoggerBackend::Stderr;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{params} = $params->{params};
  bless $self;
}

sub addMsg {

  my ($self, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;
  
  # STDERR has been hijacked, I take its saved ref
  my $tmp = $self->{params}->{savedstderr};
  print $tmp "[$level] $message\n";
}

1;
