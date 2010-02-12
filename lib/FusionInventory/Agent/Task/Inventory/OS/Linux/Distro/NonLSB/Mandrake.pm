package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Mandrake;
use strict;

sub isInventoryEnabled {-f "/etc/mandrake-release" && !-f "/etc/mandriva-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/mandrake-release" or warn;
  chomp ($v = <V>);
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
