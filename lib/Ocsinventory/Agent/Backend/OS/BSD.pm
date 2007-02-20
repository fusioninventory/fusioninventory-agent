package Ocsinventory::Agent::Backend::OS::BSD;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /freebsd|openbsd|netbsd/ }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  # This will provable be overwrite by a Linux::Distro module.
  $inventory->setHardware({
      OSNAME => $^O,
      OSCOMMENTS => "BSD Operating system"
    });
}
1;
