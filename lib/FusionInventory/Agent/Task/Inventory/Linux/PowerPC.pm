package FusionInventory::Agent::Task::Inventory::Linux::PowerPC;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^(ppc|powerpc)/;
}

sub doInventory {
}

1;
