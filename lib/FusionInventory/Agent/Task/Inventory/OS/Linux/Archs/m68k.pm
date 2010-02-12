package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::m68k;

use strict;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^m68k/;
  0; 
};

1
