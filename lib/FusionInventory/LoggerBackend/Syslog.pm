package FusionInventory::LoggerBackend::Syslog;
# Not tested yet!
use Sys::Syslog qw( :DEFAULT setlogsock);

sub new {
  my (undef, $params) = @_;

  my $self = {};

  setlogsock('unix');
  openlog("fusioninventory-agent", 'cons,pid', $ENV{'USER'});
  syslog('debug', 'syslog backend enabled');
  closelog();

  bless $self;
}

sub addMsg {

  my (undef, $args) = @_;

  my $level = $args->{level};
  my $message = $args->{message};

  return if $message =~ /^$/;

  openlog("fusioninventory-agent", 'cons,pid', $ENV{'USER'});
  syslog('info', $message);
  closelog();

}

1;
