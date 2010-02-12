package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::SuSE;
use strict;

sub isInventoryEnabled { can_read ("/etc/SuSE-release") }

#####
sub findRelease {
  my $v;

  open V, "</etc/SuSE-release" or warn;
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
