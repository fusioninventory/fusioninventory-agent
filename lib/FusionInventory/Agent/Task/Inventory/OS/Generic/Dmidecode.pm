package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {

    if (can_run("dmidecode")) {
        my @output = `dmidecode`;

        return 1 if @output > 10;
    }

    return 0;
}

sub doInventory {}

1;
