package Ocsinventory::Agent::Backend::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /^linux$/ }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  # This will provably be overwriten by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => "Linux",
      OSCOMMENTS => "Unknow Linux distribution"
    });
}


1;
