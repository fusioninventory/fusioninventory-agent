package FusionInventory::Agent::Task::Inventory::Linux::ARM;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Config;

sub isEnabled {
    return $Config{archname} =~ /^arm/;
}

sub doInventory {
}

1;
