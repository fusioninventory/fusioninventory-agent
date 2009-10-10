package Ocsinventory::Agent::Backend::IpDiscover;

use strict;

sub isInventoryEnabled {
    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $mem = $params->{mem};

    return unless ($prologresp && $prologresp->getOptionsInfoByName("IPDISCOVER"));

    1;
}


1;
