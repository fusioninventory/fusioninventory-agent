package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::MIPS;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^mips/;
};

1;
