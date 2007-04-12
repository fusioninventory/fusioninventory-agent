package Ocsinventory::Agent::Backend::OS::Linux::Distro::Debian;
use strict;

sub check {-f "/etc/debian_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/debian_version" or warn;
  chomp ($v=<V>);
  close V;
  return "Debian GNU/Linux $v";
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
