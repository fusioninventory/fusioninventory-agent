package Ocsinventory::Agent::Backend::OS::Linux::VirtualFs::Proc::Mem;
use strict;

sub check { -r "/proc/meminfo" };

sub run {
	my $h = shift;
	my $unit = 1024;

	my $PhysicalMemory;
	my $SwapFileSize;

# Memory informations
	open MEMINFO, "/proc/meminfo";
	while(<MEMINFO>){
		$PhysicalMemory=$1 if /^memtotal\s*:\s*(\S+)/i;
		$SwapFileSize=$1 if /^swaptotal\s*:\s*(\S+)/i;
	}
	$h->{CONTENT}{'HARDWARE'}->{'MEMORY'} =  [sprintf("%i",$PhysicalMemory/$unit) ];
	$h->{CONTENT}{'HARDWARE'}->{'SWAP'} =  [ sprintf("%i", $SwapFileSize/$unit) ];

}

1
