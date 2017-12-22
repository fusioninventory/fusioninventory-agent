package FusionInventory::Agent::Task::Inventory::Linux::MIPS;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Config;

sub isEnabled {
    return $Config{archname} =~ /^mips/;
}

sub doInventory {
}

1;
