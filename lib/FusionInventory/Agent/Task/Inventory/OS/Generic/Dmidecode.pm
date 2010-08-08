package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {

    return can_run("dmidecode");
}

sub doInventory {}

1;
