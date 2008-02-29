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
  
  # if STDERR has been hijacked, I take its saved ref
  my $stderr;
  if (exists ($self->{params}->{savedstderr})) {
    $stderr = $self->{params}->{savedstderr};
  } else {
    open ($stderr, ">&STDERR");
  }


  print $stderr "[$level] $message\n";

}

1;
