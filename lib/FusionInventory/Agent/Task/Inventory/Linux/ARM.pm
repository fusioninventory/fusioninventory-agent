package FusionInventory::Agent::Task::Inventory::Linux::ARM;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^arm/;
}

sub doInventory {
}

1;
