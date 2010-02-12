package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Knoppix;
use strict;

sub isInventoryEnabled {-f "/etc/knoppix_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/knoppix_version" or warn;
  chomp ($v=<V>);
  close V;
  print $v."\n";
  return "Knoppix GNU/Linux $v";
}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $OSComment;
  chomp($OSComment =`uname -v`);

  $inventory->setHardware({ 
      OSNAME => findRelease(),
      OSCOMMENTS => "$OSComment"
    });
}

1;
