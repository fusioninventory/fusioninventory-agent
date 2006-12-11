package Ocsinventory::Agent::Backend::OS::Linux::Uptime;
use strict;

sub check {
  foreach (`mount`) {
    return 1 if (/type\ proc/);
  }
  return;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  # Uptime
  open UPTIME, "/proc/uptime";
  my $uptime = <UPTIME>;
  $uptime =~ s/^(.+)\s+.+/$1/;
  close UPTIME;

  # Uptime conversion
  my ($UYEAR, $UMONTH , $UDAY, $UHOUR, $UMIN, $USEC) = (gmtime ($uptime))[5,4,3,2,1,0];

  # Write in ISO format
  # TODO date is broken
  # XXX since uptime is never the same, that's force the server to refresh
  # HARDWARE section without real reason. I prefere to comment it.
#        $uptime=sprintf "%02d-%02d-%02d %02d:%02d:%02d", ($UYEAR-70), $UMONTH, ($UDAY-1), $UHOUR, $UMIN, $USEC;

  chomp(my $DeviceType =`uname -m`);
  #$inventory->setHardware({'DESCRIPTION' => "$DeviceType/$uptime"});
  $inventory->setHardware({'DESCRIPTION' => "$DeviceType"});
}

1
