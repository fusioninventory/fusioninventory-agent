package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC;

use strict;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^(ppc|powerpc)/;
  0; 
};

1
