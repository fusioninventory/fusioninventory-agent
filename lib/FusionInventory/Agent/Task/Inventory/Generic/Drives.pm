package FusionInventory::Agent::Task::Inventory::Generic::Drives;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{drive};
    return 1;
}

sub doInventory {}

1;
