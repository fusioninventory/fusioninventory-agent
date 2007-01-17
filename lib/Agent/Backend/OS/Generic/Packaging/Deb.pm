package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Deb;

use strict;
use warnings;

#sub check {my $p = `which dpkg`; $p}
sub check {0}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`COLUMNS=200 dpkg -l`){
    if (/^[uirph]/){
      /^(\w+)\s+(\S+)\s+(\S+)\s+(.*)/;
      $inventory->addSoftwares ({
	  'NAME'          => $2,
	  'VERSION'       => $3,
	  'COMMENTS'      => "$4($1)",
	});
    }

  }

}

1;
