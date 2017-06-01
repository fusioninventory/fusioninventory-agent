package FusionInventory::Agent::Task::Inventory::Containers;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{containers};
    return 1;
}

sub doInventory {
}

1;
