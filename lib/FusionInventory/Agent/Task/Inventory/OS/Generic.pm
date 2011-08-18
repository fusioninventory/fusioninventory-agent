package FusionInventory::Agent::Task::Inventory::OS::Generic;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    $inventory->setOS({
        KERNEL_NAME => $OSNAME
    });
}

1;
