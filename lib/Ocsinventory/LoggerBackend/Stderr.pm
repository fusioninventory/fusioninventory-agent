package Ocsinventory::LoggerBackend::Stderr;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{config} = $params->{config};
  bless $self;
}

sub addMsg {

  my ($self, $args) = @_;

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


  print $stderr "[$level] $message\n";

}

1;
