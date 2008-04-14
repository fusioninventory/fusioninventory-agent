package Ocsinventory::Agent::Backend::OS::Solaris::Slots;

use strict;
sub check { can_run ("prtdiag") }

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
