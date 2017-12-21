package FusionInventory::Agent::Task::Inventory::Virtualization;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{virtualmachine};
    return 1;
}

sub isEnabledForRemote {
    my (%params) = @_;
    return 0 if $params{no_category}->{virtualmachine};
    return 1;
}

sub doInventory {
}

1;
