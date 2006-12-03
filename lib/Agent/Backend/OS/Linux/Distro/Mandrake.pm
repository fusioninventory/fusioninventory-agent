package Ocsinventory::Agent::Backend::OS::Linux::Distro::Mandrake;
use strict;

sub check {-f "/etc/mandrake-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/mandrake-release" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Mandrake / $v";
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
