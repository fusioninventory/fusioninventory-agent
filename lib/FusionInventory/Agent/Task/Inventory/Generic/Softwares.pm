package FusionInventory::Agent::Task::Inventory::Generic::Softwares;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

sub isEnabled {
    my (%params) = @_;
    return 0 if !$params{category}->{software};
    return 1;
}

sub doInventory {}

1;
