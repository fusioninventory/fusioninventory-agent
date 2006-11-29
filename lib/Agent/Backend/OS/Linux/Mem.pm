package Ocsinventory::Agent::Backend::OS::Linux::Mem;
use strict;

sub check { -r "/proc/meminfo" };

sub run {
	my $inventory = shift;

	my $h = shift;
	my $unit = 1024;

	my $memory;
	my $swap;

# Memory informations
	open MEMINFO, "/proc/meminfo" or warn;
	while(<MEMINFO>){
		$memory=int ($1/$unit) if /^memtotal\s*:\s*(\S+)/i;
		$swap=int ($1/$unit) if /^swaptotal\s*:\s*(\S+)/i;
	}
	close MEMINFO;

	
	$inventory->setHardware({
	  MEMORY => $memory,
	  SWAP => $swap 
	  });

}

1
