package Ocsinventory::Agent::Pid;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  my $logger = $self->{logger} = $params->{logger};
  my $params = $self->{params} = $params->{params};

  if ( -f $params->{pidfile} ) {
    $logger->error("Pidfile: `".$params->{pidfile}."' already exists. I'm going to overwrite it.");
  }

  if (!open PID, ">". $params->{pidfile}) {
    $logger->error("Can't store the PID in `".$params->{pidfile}."'");
  } else {
    print PID "$$\n";
    close PID or warn;
  }
}


1;
