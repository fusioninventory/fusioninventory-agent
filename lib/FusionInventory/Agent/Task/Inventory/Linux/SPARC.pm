package FusionInventory::Agent::Task::Inventory::Linux::SPARC;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Config;

sub isEnabled {
    return $Config{archname} =~ /^sparc/;
};

sub doInventory {
}

1;
