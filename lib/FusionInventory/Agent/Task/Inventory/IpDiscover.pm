package FusionInventory::Agent::Task::Inventory::IpDiscover;

use strict;
use warnings;

sub isInventoryEnabled {
    my $params = shift;

    my $prologresp = $params->{prologresp};

    return
        $prologresp &&
        $prologresp->getOptionsInfoByName("IPDISCOVER");
}

1;
