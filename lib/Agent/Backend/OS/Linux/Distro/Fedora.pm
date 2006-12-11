package Ocsinventory::Agent::Backend::OS::Linux::Distro::Fedora;
use strict;

sub check {-f "/etc/fedora-release"}

#####
sub findRelease {
  my $v;

  open V, "</etc/fedora-release" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Fedora Core / $v";
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $OSComment;
  chomp($OSComment =`uname -v`);

  $inventory->setHardware({ 
      OSCOMMENTS => findRelease()." / $OSComment"
    });
}



1;
