package Ocsinventory::Agent::Backend::OS::Linux::Distro::NonLSB::SuSE;
use strict;

sub check { can_read ("/etc/SuSE-release") }

#####
sub findRelease {
  my $v;

  open V, "</etc/SuSE-release" or warn;
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
