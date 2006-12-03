package Ocsinventory::Agent::Backend::OS::Linux::Distro::Knoppix;
use strict;

sub check {-f "/etc/knoppix_version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/knoppix_version" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Knoppix / $v";
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
