package Ocsinventory::Agent::Backend::OS::Linux::Distro::NonLSB::ArchLinux;
use strict;

sub check {-f "/etc/arch-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/arch-release" or warn;
  chomp ($v=<V>);
  close V;
  return "ArchLinux $v";
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
