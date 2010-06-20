package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    if ($OSNAME ne 'MSWin32') {
        return unless -r "/dev/mem";
    }
    return unless can_run("dmidecode");

    1;
}

sub doInventory {}

1;
