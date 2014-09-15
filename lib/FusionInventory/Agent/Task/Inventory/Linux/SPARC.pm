package FusionInventory::Agent::Task::Inventory::Linux::SPARC;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^sparc/;
};

sub doInventory {
}

1;
