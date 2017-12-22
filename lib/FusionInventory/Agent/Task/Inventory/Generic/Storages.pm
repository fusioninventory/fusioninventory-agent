package FusionInventory::Agent::Task::Inventory::Generic::Storages;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{storage};
    return 1;
}

sub doInventory {}

1;
