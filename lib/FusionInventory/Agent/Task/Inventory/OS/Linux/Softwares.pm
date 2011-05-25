package FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return !$params{no_software};
}

sub doInventory {
}

1;
