package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Gentoo;
use strict;

sub isInventoryEnabled {-f "/etc/gentoo-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/gentoo-release" or warn;
  chomp ($v=<V>);
  close V;
  return "Gentoo Linux $v";
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
