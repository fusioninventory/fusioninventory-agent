package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Deb;

use strict;
use warnings;

sub check {
  `which dpkg 2>&1`;
  return if ($? >> 8)!=0;
  `dpkg 2>&1`;
  return if ($? >> 8)!=2;
  1;
}

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
