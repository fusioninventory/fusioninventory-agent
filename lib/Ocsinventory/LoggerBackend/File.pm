package Ocsinventory::LoggerBackend::File;
use strict;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{params} = $params->{params};
  $self->{logfile} = $self->{params}->{logdir}."/".$self->{params}->{logfile};


  bless $self;
}

sub addMsg {

  my ($self, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  open FILE, ">>$self->{logfile}" or warn "Can't open ".
  "`$self->{params}->{logfile}'\n";
  print FILE "[".localtime()."][$level] $message\n";
  close FILE;

}

1;
