package Ocsinventory::LoggerBackend::Stderr;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  # STDERR has been hijacked, I take its saved ref
  $self->{params} = $params->{params};
  bless $self;
}

sub addMsg {

  my ($self, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;
  my $tmp = $self->{params}->{savedstderr};
  print $tmp "[$level] $message\n";
}

1;
