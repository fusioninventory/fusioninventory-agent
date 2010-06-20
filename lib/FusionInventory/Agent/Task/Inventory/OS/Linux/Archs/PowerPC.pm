package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC;

use strict;
use warnings;

use Config;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^(ppc|powerpc)/;
};

1;
