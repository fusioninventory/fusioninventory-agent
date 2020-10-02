package FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::IpmiFru;

sub isEnabled {
    return canRun('ipmitool') && getIpmiFru();
}

sub doInventory {}

1;
