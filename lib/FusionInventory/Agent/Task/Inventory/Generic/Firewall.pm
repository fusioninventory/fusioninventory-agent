package FusionInventory::Agent::Task::Inventory::Generic::Firewall;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{firewall};
    return 1;
}

sub doInventory {}

1;
