package FusionInventory::Agent::Task::Inventory::AccessLog;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $date = getFormatedLocalTime(time());

    $inventory->setAccessLog ({
        USERID => 'N/A',
        LOGDATE => $date
    });
}

1;
