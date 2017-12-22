package FusionInventory::Agent::Task::Inventory::Linux::Alpha;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use Config;

sub isEnabled {
    return $Config{archname} =~ /^alpha/;
};

sub doInventory {
}

1;
