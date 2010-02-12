package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::Alpha;

use strict;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^alpha/;
  0; 
};

1
