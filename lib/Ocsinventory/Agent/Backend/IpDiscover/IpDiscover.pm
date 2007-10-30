package Ocsinventory::Agent::Backend::IpDiscover::IpDiscover;

use strict;

sub check {
    my $params = shift;

    # Do we have ipdiscover?
    `ipdiscover 2>&1`;
    if (($? >> 8)==0) {
	$mem->{scanmode} = "ipdiscover";
	return 1; 
    }
    
    0;
}


sub run {
    my $params = shift;

    my $inventory = $params->{inventory};
    my $prologresp = $params->{prologresp};

	# Let's find network interfaces and call ipdiscover on it
	my $options = $prologresp->getOptionInfoByName("IPDISCOVER");
	my $ipdisc_lat;
	if (exists($optiond->{IPDISC_LAT})) {
	    $ipdisc_lat = $optiond->{IPDISC_LAT};
	}

	my $legacymode;
	if( `ipdiscover` =~ /binary ver. (\d+)/ ){
	    $legacymode = 1 unless ( $1>3 );
	}

	my @if;
	foreach (`ifconfig`) {
	    push @if, $1 if /^(\S*)/;
	}

	foreach (@if) {

	}


}

1;
