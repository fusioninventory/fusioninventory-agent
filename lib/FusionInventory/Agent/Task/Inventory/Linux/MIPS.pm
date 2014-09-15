package FusionInventory::Agent::Task::Inventory::Linux::MIPS;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^mips/;
}

sub doInventory {
}

1;
