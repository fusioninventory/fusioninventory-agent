package Ocsinventory::Agent::Backend::OS::Linux;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /^linux$/ }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  chomp (my $osversion = `uname -r`);

  # This will probably be overwritten by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => "Linux",
      OSCOMMENTS => "Unknow Linux distribution",
      OSVERSION => $osversion
    });
}

1;
