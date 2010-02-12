package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Mandriva;
use strict;

sub isInventoryEnabled {-f "/etc/mandrake-release" && -f "/etc/mandriva-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/mandriva-release" or warn;
  chomp ($v=<V>);
  close V;
  return $v if $v;

  0;
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
