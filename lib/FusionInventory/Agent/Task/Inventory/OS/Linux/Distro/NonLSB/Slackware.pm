package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::NonLSB::Slackware;
use strict;

sub isInventoryEnabled {-f "/etc/slackware-version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/slackware-version" or warn;
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
