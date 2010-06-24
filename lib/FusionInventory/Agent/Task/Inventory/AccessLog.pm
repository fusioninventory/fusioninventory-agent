package FusionInventory::Agent::Task::Inventory::AccessLog;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($year, $month , $day, $hour, $min, $sec) = (localtime
        (time))[5,4,3,2,1,0];

    my $date = getFormatedDate(
        ($year + 1900), ($month + 1), $day, $hour, $min, $sec
    );

    $inventory->setAccessLog ({
        USERID => 'N/A',
        LOGDATE => $date
    });

}

1;
