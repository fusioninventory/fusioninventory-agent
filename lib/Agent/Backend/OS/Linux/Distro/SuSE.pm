package Ocsinventory::Agent::Backend::OS::Linux::Distro::SuSE;
use strict;

sub check {-f "/etc/SuSE-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/SuSE-release" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "SuSe Linux $v";
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
