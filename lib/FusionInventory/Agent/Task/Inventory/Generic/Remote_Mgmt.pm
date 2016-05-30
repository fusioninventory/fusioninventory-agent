package FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return !($params{no_category}->{remote_mgmt});
}

sub doInventory {
}

1;
