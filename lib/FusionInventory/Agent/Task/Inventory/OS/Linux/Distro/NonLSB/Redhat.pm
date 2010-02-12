package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Redhat;
use strict;

sub isInventoryEnabled {
    -f "/etc/redhat-release"
      &&
    !readlink ("/etc/redhat-release")
      &&
    !-f "/etc/vmware-release"
}

####
sub findRelease {
  my $v;

  open V, "</etc/redhat-release" or warn;
  chomp ($v=<V>);
  close V;
  $v;
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
