package Ocsinventory::Agent::Backend::OS::Solaris;

use strict;
sub check {
  my $r;
  $r = 1 if $^O =~ /^solaris$/;
  $r;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  # TODO
}


1;
