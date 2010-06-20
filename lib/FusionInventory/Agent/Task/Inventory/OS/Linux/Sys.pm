package FusionInventory::Agent::Task::Inventory::OS::Linux::Sys;

use strict;
use warnings;

#$LunchAfter = "FusionInventory::Agent::Task::Inventory::OS::Linux::VirtualFs::Sys";

sub isInventoryEnabled {
    return unless can_run ("mount");
    foreach (`mount`) {
        return 1 if (/type\ sysfs/);
    }
    0;
}

sub doInventory {}

1;
