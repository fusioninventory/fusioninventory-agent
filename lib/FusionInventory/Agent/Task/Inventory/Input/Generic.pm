package FusionInventory::Agent::Task::Inventory::Input::Generic;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    $inventory->setOperatingSystem({
        KERNEL_NAME => $OSNAME
    });
}

1;
