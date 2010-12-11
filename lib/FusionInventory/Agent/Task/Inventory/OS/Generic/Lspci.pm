package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lspci');
}

sub doInventory {}

1;
