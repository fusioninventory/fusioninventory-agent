package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::m68k;

use strict;
use warnings;

use Config;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^m68k/;
};

1;
