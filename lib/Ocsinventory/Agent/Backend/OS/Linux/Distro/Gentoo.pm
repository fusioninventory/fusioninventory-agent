package Ocsinventory::Agent::Backend::OS::Linux::Distro::Gentoo;
use strict;

sub check {-f "/etc/gentoo-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/gentoo-release" or warn;
  chomp ($v=<V>);
  close V;
  return "Gentoo Linux $v";
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
