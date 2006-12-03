package Ocsinventory::Agent::Backend::OS::Linux::Distro::Debian;
use strict;

sub check {-f "/etc/debian_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/debian_version" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Debian / $v";
}

sub run {
  my $inventory = shift;
  my $OSComment;
  chomp($OSComment =`uname -v`);

  $inventory->setHardware({ 
      OSCOMMENTS => findRelease()." / $OSComment"
    });
}

1;
