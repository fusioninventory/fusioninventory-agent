package Ocsinventory::Logger;
# TODO use Log::Log4perl instead.
use Carp;
sub new {

  my (undef, $params) = @_;

  my $self = {};
  bless $self;
  $self->{backend} = [];
  $self->{params} = $params->{params};

  $self->{debug} = $self->{params}->{debug}?1:0;
#  print "Logging backend(s): ".$self->{params}->{logger}."\n";
  my @logger;

  if (exists ($self->{params}->{logger})) {
    @logger = split /,/, $self->{params}->{logger};
  } else {
    # if no 'logger' parameter exist I use Stderr as default backend
    push @logger, 'Stderr';
  }

  foreach (@logger) {
    my $backend = "Ocsinventory::LoggerBackend::".$_;
    eval ("require $backend"); # TODO deal with error
    my $obj = new $backend ({
      params => $self->{params},
      });
    push @{$self->{backend}}, $obj if $obj;
  }
  
  my $version = "Ocsinventory unified agent for UNIX and Linux";
  $version .= exists ($self->{params}->{VERSION})?$self->{params}->{VERSION}:'';
  $self->debug($version."\n");
  $self->debug("Log system initialised");

  $self;
}

sub log {
  my ($self, $args) = @_;

  # levels: info, debug, warn, fault
  my $level = $args->{level};
  my $message = $args->{message};

  return if ($level =~ /^debug$/ && !($self->{debug}));

  chomp($message);
  $level = 'info' unless $level;

  foreach (@{$self->{backend}}) {
    $_->addMsg ({
      level => $level,
      message => $message
    });
  }
  confess if $level =~ /^fault$/; # Die with a backtace 
}

sub debug {
  my ($self, $msg) = @_;
  $self->log({ level => 'debug', message => $msg});
}

sub info {
  my ($self, $msg) = @_;
  $self->log({ level => 'info', message => $msg});
}

sub error {
  my ($self, $msg) = @_;
  $self->log({ level => 'error', message => $msg});
}

sub fault {
  my ($self, $msg) = @_;
  $self->log({ level => 'fault', message => $msg});
}

sub user {
  my ($self, $msg) = @_;
  $self->log({ level => 'user', message => $msg});
}

1;
