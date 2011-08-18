package FusionInventory::Agent::Task::Inventory::OS::Generic;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    $inventory->setOperatingSystem({
        KERNEL_NAME    => $OSNAME
    });

}

1;
