package FusionInventory::Agent::Task::Inventory::Virtualization;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{virtualmachine};
    return 1;
}

sub doInventory {
}

1;
