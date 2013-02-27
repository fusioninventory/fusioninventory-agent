package FusionInventory::Agent::Task::Inventory::AccessLog;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $date = getFormatedLocalTime(time());

    $inventory->setAccessLog ({
        LOGDATE => $date
    });
}

1;
