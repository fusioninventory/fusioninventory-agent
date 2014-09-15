package FusionInventory::Agent::Task::Inventory::Linux::m68k;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^m68k/;
}

sub doInventory {
}

1;
