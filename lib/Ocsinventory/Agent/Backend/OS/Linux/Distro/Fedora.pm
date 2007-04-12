package Ocsinventory::Agent::Backend::OS::Linux::Distro::Fedora;
use strict;

sub check {-f "/etc/fedora-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/fedora-release" or warn;
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
