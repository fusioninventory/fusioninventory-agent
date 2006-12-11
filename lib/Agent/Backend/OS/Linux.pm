package Ocsinventory::Agent::Backend::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::POSIX"];

sub check {
  my $r;
  $r = 1 if $^O =~ /^linux$/;
  $r;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  # This will provable be overwrite by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => "Linux",
      OSCOMMENTS => "Unknow Linux distribution"
    });
}


1;
