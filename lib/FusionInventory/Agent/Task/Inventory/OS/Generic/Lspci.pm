package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci;

use strict;
use warnings;

sub isInventoryEnabled {can_run("lspci")}

sub doInventory {}

1;
