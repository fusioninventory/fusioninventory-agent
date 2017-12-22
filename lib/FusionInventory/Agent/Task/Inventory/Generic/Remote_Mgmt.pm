package FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

sub isEnabled {
    my (%params) = @_;
    return !($params{no_category}->{remote_mgmt});
}

sub isEnabledForRemote {
    my (%params) = @_;
    return !($params{no_category}->{remote_mgmt});
}

sub doInventory {
}

1;
