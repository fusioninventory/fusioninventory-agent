package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Ubuntu;
use strict;

use vars qw($runAfter);
$runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Debian"];

sub isInventoryEnabled {-f "/etc/ubuntu_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/ubuntu_version" or warn;
  chomp ($v=<V>);
  close V;
  return "Ubuntu $v";
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
