package FusionInventory::Agent::Task::Inventory::Linux::i386;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^(i\d86|x86_64)/;
}

sub doInventory {
}

1;
