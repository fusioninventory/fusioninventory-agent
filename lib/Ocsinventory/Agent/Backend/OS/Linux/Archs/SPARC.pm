package Ocsinventory::Agent::Backend::OS::Linux::Archs::SPARC;

use strict;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^sparc/;
  0; 
};

1
