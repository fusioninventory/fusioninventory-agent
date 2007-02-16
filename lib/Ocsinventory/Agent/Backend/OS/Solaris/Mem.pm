package Ocsinventory::Agent::Backend::OS::Solaris::Mem;

use strict;

sub check {
  `swap -l 2>&1`;
  return if ($? >> 8)!=0;

  `prtconf 2>&1`;
  return if ($? >> 8)!=0;
  1;
};

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
#my $unit = 1024;

  my $PhysicalMemory;
  my $SwapFileSize;

# Memory informations
  foreach(`prtconf`){
    if(/^Memory\ssize:\s+(\S+)/){$PhysicalMemory = $1}; 	
  } 
#Swap Informations 
  foreach(`swap -l`){
    if(/\s+(\S+)$/){$SwapFileSize += $1}; 
  }

  $inventory->setHardware({
      MEMORY =>  $PhysicalMemory,
      SWAP =>    $SwapFileSize
      });
}

1
