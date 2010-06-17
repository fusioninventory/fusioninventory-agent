package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386;

use strict;
use warnings;

use Config;

sub isInventoryEnabled { 
  return 1 if $Config{'archname'} =~ /^(i\d86|x86_64)/;
  0; 
};

1
