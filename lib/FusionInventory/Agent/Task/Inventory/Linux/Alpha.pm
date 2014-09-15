package FusionInventory::Agent::Task::Inventory::Linux::Alpha;

use strict;
use warnings;

use Config;

sub isEnabled {
    return $Config{archname} =~ /^alpha/;
};

sub doInventory {
}

1;
