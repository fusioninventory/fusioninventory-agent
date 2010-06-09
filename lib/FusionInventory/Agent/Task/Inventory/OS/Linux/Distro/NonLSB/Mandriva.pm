package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Mandriva;
use strict;

sub isInventoryEnabled {
    return
        -f "/etc/mandriva-release" ||
        -f "/etc/mandrake-release";
}

#####
sub findRelease {
  my $v;

  my $file = -f "/etc/mandriva-release" ?
    "/etc/mandriva-release" : "/etc/mandrake-release";

  open V, '<', $file or warn;
  chomp ($v = <V>);
  close V;

  return $v ? $v : 0;
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
