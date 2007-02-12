package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Gentoo;

use strict;
use warnings;

sub check {
  `which equery 2>&1`;
  return if ($? >> 8)!=0;
  `equery 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

# TODO: This had been rewrite from the Linux agent _WITHOUT_ being checked!
  foreach (`equery list -i`){
    if (/^([a-z]\w+-\w+\/\w+)-([0-9]+.*)/) {
      $inventory->addSoftwares({
	  'NAME'          => $1,
	  'VERSION'       => $2,
	  });
    }
  }
}

1;
