package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::ARM;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return $Config{'archname'} =~ /^arm/;
};

1;
