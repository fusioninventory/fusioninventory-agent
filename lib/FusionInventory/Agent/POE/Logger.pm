package FusionInventory::Agent::POE::Logger;

sub new {
    my $self = {};
    
    bless $self;
}

sub debug {
  my ($self, $msg) = @_;

  sendError('debug', $msg);
}

sub info {
  my ($self, $msg) = @_;

  sendError('info', $msg);
}

sub error {
  my ($self, $msg) = @_;

  sendError('error', $msg);
}

sub fault {
  my ($self, $msg) = @_;

  sendError('fault', $msg);
}

sub user {
  my ($self, $msg) = @_;

  sendError('user', $msg);
}


1;
