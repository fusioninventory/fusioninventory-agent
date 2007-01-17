package Ocsinventory::LoggerBackend::File;

sub new {
  my (undef, $params) = @_;

  return unless $params->{logfile};

  my $self = {};
  $self->{logfile} = $params->{logfile};

  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  open FILE, ">>$self->{logfile}" or warn;
  print FILE "[".localtime()."][$level] $message";
  close FILE;

}

1;
