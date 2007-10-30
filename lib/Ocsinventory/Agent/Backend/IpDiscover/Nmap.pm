package Ocsinventory::Agent::Backend::IpDiscover::Nmap;

use strict;

sub check {
    my $params = shift;

    # Do we have nmap 3.90 (or >) 
    foreach (`nmap -v 2>&1`) {
	if (/^Starting Nmap (\d+)\.(\d+)/) {
	    my $release = $1;
	    my $minor = $2;

	    if ($release > 3 || ($release > 3 && $minor >= 90)) {
		return 1;
	    }
	}
    }

    0;
}


sub run {
    my $params = shift;

    my $inventory = $params->{inventory};
# nmap -sP -PR '192.168.1.0/24'


}

1;
