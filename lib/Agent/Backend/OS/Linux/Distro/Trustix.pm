package Ocsinventory::Agent::Backend::OS::Linux::Distro::Trustix;
use strict;

sub check {-f "/etc/trustix-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/trustix-release" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Trustix Linux $v";
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
