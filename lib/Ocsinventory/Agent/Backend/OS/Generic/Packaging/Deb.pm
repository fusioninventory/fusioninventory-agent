package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Deb;

use strict;
use warnings;

sub check { can_run("dpkg") }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

# use dpkg-query -W -f='${Package}|||${Version}\n'
  foreach(`COLUMNS=200 dpkg -l`) {
     if (/^ii\s+(\S+)\s+(\S+)\s+(.*)/) {
      $inventory->addSoftwares ({
	  'NAME'          => $1,
	  'VERSION'       => $2,
	  'COMMENTS'      => $3,
	  });
    }

  }

}

1;
