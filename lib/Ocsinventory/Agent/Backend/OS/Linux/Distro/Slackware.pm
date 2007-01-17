package Ocsinventory::Agent::Backend::OS::Linux::Distro::Slackware;
use strict;

sub check {-f "/etc/slackware-version"}

#####
sub findRelease {
  my $v;

  open V, "</etc/slackware-version" or warn;
  chomp ($v = readline V);
  close V;
  print $v."\n";
  return "Slackware Linux $v";
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
