package FusionInventory::Agent::Task::Inventory::Linux::AntiVirus;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub doInventory {
}
1;
