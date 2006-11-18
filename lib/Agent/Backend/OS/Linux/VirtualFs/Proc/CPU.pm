package Ocsinventory::Agent::Backend::OS::Linux::VirtualFs::Proc::CPU;
use strict;

sub check { -r "/proc/cpuinfo" };

sub run {
	my $h = shift;

# TODO Need to be able to register different CPU speed!

	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORT} = [ "??" ];
	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORS} = [ "??" ];
	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORN} = [ 0 ];
	open CPUINFO, "</proc/cpuinfo" or warn;
        foreach(<CPUINFO>){
                $h->{'CONTENT'}{'HARDWARE'}{PROCESSORT}[0]++ if (/^processor\s*:/);
                $h->{'CONTENT'}{'HARDWARE'}{PROCESSORN}[0] = $1 if (/^model name\s*:\s*(.+)/i);
                $h->{'CONTENT'}{'HARDWARE'}{PROCESSORS}[0] = $1 if (/^cpu mhz\s*:\s*(\S+)\n/i);
        }
	close CPUINFO;

}

1
