package FusionInventory::Agent::Task::Inventory::AccessLog;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $date = getFormatedLocalTime(time());

    $inventory->setAccessLog ({
        USERID => 'N/A',
        LOGDATE => $date
    });

}

1;
