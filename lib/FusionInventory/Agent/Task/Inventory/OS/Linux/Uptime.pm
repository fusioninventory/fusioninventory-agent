package FusionInventory::Agent::Task::Inventory::OS::Linux::Uptime;
use strict;

sub isInventoryEnabled { can_read("/proc/uptime") }

sub doInventory {
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
  $uptime=sprintf "%02d-%02d-%02d %02d:%02d:%02d", ($UYEAR-70), $UMONTH, ($UDAY-1), $UHOUR, $UMIN, $USEC;
  
  chomp(my $DeviceType =`uname -m`);
#  TODO$h->{'CONTENT'}{'HARDWARE'}{'DESCRIPTION'} = [ "$DeviceType/$uptime" ];
  $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1
