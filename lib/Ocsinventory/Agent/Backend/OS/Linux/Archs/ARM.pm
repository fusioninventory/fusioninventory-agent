package Ocsinventory::Agent::Backend::OS::Linux::Archs::ARM;

use strict;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^arm/;
  0; 
};

1
