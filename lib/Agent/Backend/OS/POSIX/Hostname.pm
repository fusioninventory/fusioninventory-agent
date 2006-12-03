package Ocsinventory::Agent::Backend::OS::POSIX::Hostname;

sub check {1} # No check yet

# Initialise the distro entry
sub run {
	my $h = shift;

	my $hostname;
        
	chomp ( my $hostname = `hostname` );

	$h->{'CONTENT'}{'HARDWARE'}{'NAME'} = [$hostname];

}

1;
