package Ocsinventory::Agent::Backend::OS::Generic;

use strict;

sub check {
  my $r;
  $r = 1 if $^O =~ /^(linux|aix|solaris|freebsd|netbsd|openbsd)$/;
  $r;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  chomp(my $OSVersion =`uname -r`);
  chomp(my $OSComment =`uname -v`);

  # Will be overwrite by a more specific module
  $inventory->setHardware({
      OSNAME => "Generic OS",
      OSVERSION => $OSVersion,
      OSCOMMENTS => "Unknow $^O system",
      TYPE => 8,
    });
}


1;
