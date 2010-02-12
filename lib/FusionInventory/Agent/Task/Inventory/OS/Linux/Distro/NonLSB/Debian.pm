package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Debian;
use strict;

sub isInventoryEnabled {-f "/etc/debian_version" && !-f "/etc/ubuntu_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/debian_version" or warn;
  chomp ($v=<V>);
  close V;
  return "Debian GNU/Linux $v";
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
