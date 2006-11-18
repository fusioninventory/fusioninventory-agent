package Ocsinventory::Agent::Backend::OS::Linux::Network::IPv4;

sub check {
	my @ifconfig = `ifconfig 2>/dev/null`;
	return 1 if @ifconfig;
	return;
}

# Initialise the distro entry
sub run {
	my $h = shift;

	my @ip;
	for(`ifconfig`){
		if(/^\s*inet add?r\s*:\s*(\S+)/){
			($1=~/127.+/)?next:push @ip, $1
		};
	}

	my $ip=join "/", @ip;

	$h->{'CONTENT'}{'HARDWARE'}{'IPADDR'} = [$ip];

}



1;
