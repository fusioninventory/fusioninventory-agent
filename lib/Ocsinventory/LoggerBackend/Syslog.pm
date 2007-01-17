package Ocsinventory::LoggerBackend::Syslog;
# Not tested yet!
use Sys::Syslog qw( :DEFAULT setlogsock);

sub new {
  my (undef, $params) = @_;

  my $self = {};

  setlogsock('unix');
  openlog("ocs-agent", 'cons,pid', $ENV{'USER'}) or die;
  syslog('debug', 'syslog backend enabled') or die;
  closelog();

  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  syslog($level, $message) or die;
  closelog() or die;

}

1;
