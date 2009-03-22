package Ocsinventory::Agent::Backend::OS::Linux::Archs::m68k;

use strict;

use Config;

sub check { 
  return 1 if $Config{'archname'} =~ /^m68k/;
  0; 
};

1
