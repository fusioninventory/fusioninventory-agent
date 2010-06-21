package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::SPARC;

use strict;
use warnings;

use Config;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^sparc/;
};

1;
