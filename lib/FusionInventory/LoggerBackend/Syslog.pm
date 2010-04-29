package FusionInventory::LoggerBackend::Syslog;
# Not tested yet!
use Sys::Syslog qw( :DEFAULT setlogsock);

sub new {
  my (undef, $params) = @_;

  my $self = {};

  openlog("fusinv-agent", 'cons,pid', $params->{config}->{logfacility});


  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  syslog('info', $message);

}

sub DESTROY {
  closelog();
}


1;
