package Ocsinventory::Agent::Backend::IpDiscover;

use strict;

sub check {
    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $mem = $params->{mem};

    return unless ($prologresp && $prologresp->getOptionInfoByName("IPDISCOVER"));

    1;
}


1;
