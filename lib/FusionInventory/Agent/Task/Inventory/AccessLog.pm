package FusionInventory::Agent::Task::Inventory::AccessLog;

use strict;
use warnings;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
        (time))[5,4,3,2,1,0];
    my $date=sprintf "%02d-%02d-%02d %02d:%02d:%02d",
    ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;

    $inventory->setAccessLog ({
        USERID => 'N/A',
        LOGDATE => $date
    });

}

1;
