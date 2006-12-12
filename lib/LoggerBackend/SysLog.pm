package Ocsinventory::LoggerBackend::File;
# Not tested yet!
use Sys::Syslog;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  openlog("ocs-client", 'cons,pid', 'user');
  syslog($level, $message);
  closelog();

}

1;
