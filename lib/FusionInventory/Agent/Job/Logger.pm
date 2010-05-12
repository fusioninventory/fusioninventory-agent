package FusionInventory::Agent::Job::Logger;

sub new {
    my $self = {};
    
    bless $self;
}

sub _print {
    my ($self, $level, $msg) = @_;

    print STDERR "$level: $msg\n";
}

sub debug {
  my ($self, $msg) = @_;

  _print('debug', $msg);
}

sub info {
  my ($self, $msg) = @_;

  _print('info', $msg);
}

sub error {
  my ($self, $msg) = @_;

  _print('error', $msg);
}

sub fault {
  my ($self, $msg) = @_;

  _print('fault', $msg);
}

sub user {
  my ($self, $msg) = @_;

  _print('user', $msg);
}


1;
