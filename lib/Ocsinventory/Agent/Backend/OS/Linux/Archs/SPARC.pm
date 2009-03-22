package Ocsinventory::Agent::Backend::OS::Linux::Archs::SPARC;

use strict;

use Config;

sub check { 
  return 1 if $Config{'archname'} =~ /^sparc/;
  0; 
};

1
