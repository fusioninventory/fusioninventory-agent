package Ocsinventory::Agent::Backend::OS::Linux::Distro::NonLSB::Redhat;
use strict;

sub check {
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

sub run {
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
