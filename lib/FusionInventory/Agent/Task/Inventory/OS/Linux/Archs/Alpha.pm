package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::Alpha;

use strict;
use warnings;

use Config;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^alpha/;
};

1;
