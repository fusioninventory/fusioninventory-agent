package Ocsinventory::Agent::Backend::OS::Linux::CPU;
use strict;

sub check { -r "/proc/cpuinfo" };

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
# TODO Need to be able to register different CPU speed!

#	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORT} = [ "??" ];
#	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORS} = [ "??" ];
#	$h->{'CONTENT'}{'HARDWARE'}{PROCESSORN} = [ 0 ];
  my $processort;
  my $processorn;
  my $processors;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processort++ if (/^processor\s*:/);
    $processorn = $1 if (/^model name\s*:\s*(.+)/i);
    $processors = $1 if (/^cpu mhz\s*:\s*(\S+?)(|\.\d+)\n/i);
  }
  close CPUINFO;
  $inventory->setHardware({
      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });

}

1
