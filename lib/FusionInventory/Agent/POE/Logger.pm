package FusionInventory::Agent::POE::Logger;

sub new {
    my $self = {};
    
    bless $self;
}

sub _sendError {
    my ($level, $msg) = @_;

    print STDERR "$level: $msg\n";
}

sub debug {
  my ($self, $msg) = @_;

  _sendError('debug', $msg);
}

sub info {
  my ($self, $msg) = @_;

  _sendError('info', $msg);
}

sub error {
  my ($self, $msg) = @_;

  _sendError('error', $msg);
}

sub fault {
  my ($self, $msg) = @_;

  _sendError('fault', $msg);
}

sub user {
  my ($self, $msg) = @_;

  _sendError('user', $msg);
}


1;
