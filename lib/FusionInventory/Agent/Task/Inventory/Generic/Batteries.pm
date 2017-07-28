package FusionInventory::Agent::Task::Inventory::Generic::Batteries;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{battery};
    return 1;
}

sub doInventory {}

1;
