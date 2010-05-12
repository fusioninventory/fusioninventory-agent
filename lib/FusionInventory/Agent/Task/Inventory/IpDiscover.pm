package FusionInventory::Agent::Task::Inventory::IpDiscover;

use strict;

sub isInventoryEnabled {
    my $params = shift;

    my $prologresp = $params->{prologresp};

    return unless ($prologresp && $prologresp->getOptionsInfoByName("IPDISCOVER"));

    1;
}


1;
