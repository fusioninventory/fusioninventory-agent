package FusionInventory::Agent::Task::Inventory::Linux::PowerPC;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Config;

sub isEnabled {
    return $Config{archname} =~ /^(ppc|powerpc)/;
}

sub doInventory {
}

1;
