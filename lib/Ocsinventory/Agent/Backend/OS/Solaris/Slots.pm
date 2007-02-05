package Ocsinventory::Agent::Backend::OS::Solaris::Slots;

#========================= IO Cards =========================
#
#                                Bus  Max
#            IO   Port Bus       Freq Bus  Dev,
#FRU Name    Type  ID  Side Slot MHz  Freq Func State Name                              Model
#----------  ---- ---- ---- ---- ---- ---- ---- ----- --------------------------------  ----------------------
#/N0/IB6/P0  PCI   24   B    1    33   33  2,0  ok    pci-pci8086,b154.0/network (netw+ pci-bridge
#/N0/IB6/P0  PCI   24   B    1    33   33  0,0  ok    network-pci108e,abba.20           SUNW,pci-ce
#/N0/IB6/P0  PCI   24   B    1    33   33  1,0  ok    network-pci108e,abba.20           SUNW,pci-ce
#
#========================= Active Boards for Domain ===========================


use strict;
sub check {`which prtdiag 2>&1`; ($? >> 8)?0:1}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  
  my $description;
  my $designation;
  my $name;
  my $status;  
  
  my $flag;
  my $flag_pci;
    
  foreach(`prtdiag`) {
  	#print $_."\n";
  	last if(/^\=+/ && $flag_pci);
  	next if(/^\s+/ && $flag_pci);
  	if($flag && $flag_pci && /^(\S+)\s+/){
  	   $name = $1;
  	}
  	if($flag && $flag_pci && /(\S+)\s*$/){
  	   $designation = $1;
  	}
  	if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
  	   $description = $1; 	  
  	}
  	if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
  	   $status = $1; 	  
  	}
  	if($flag && $flag_pci){
      $inventory->addSlots({
	   DESCRIPTION =>  $description,
	   DESIGNATION =>  $designation,
	   NAME 		  =>  $name,
	   STATUS	  =>  $status,
  	  }); 
  	}
	if(/^=+\s+IO Cards/){$flag_pci = 1;}	
  	if($flag_pci && /^-+/){$flag = 1;}   	
  	  
  }
}
1;
