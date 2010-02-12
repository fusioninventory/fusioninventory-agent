package FusionInventory::Agent::Task::Inventory::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled { $^O =~ /^linux$/ }

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  chomp (my $osversion = `uname -r`);

  my $lastloggeduser;
  my $datelastlog;
  my @query = runcmd("last -R");
 
  foreach ($query[0]) {
    if ( s/^(\S+)\s+\S+\s+(\S+\s+\S+\s+\S+\s+\S+)\s+.*// ) {
      $lastloggeduser = $1;
      $datelastlog = $2;
    }
  }
  
  # This will probably be overwritten by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => "Linux",
      OSCOMMENTS => "Unknown Linux distribution",
      OSVERSION => $osversion,
      LASTLOGGEDUSER => $lastloggeduser,
      DATELASTLOGGEDUSER => $datelastlog
    });
}

1;
