package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode;
use strict;

sub check {
  return unless -r "/dev/mem";

  `which dmidecode 2>&1`;
  return if ($? >> 8)!=0;
  `dmidecode 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {}

1;
