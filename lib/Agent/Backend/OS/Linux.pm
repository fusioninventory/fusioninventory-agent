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
  my $inventory = shift;

  # This will provable be overwrite by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => "Linux",
      OSCOMMENTS => "Unknow Linux distribution"
    });
}


1;
