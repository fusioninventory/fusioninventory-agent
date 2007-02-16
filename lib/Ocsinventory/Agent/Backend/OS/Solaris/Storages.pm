package Ocsinventory::Agent::Backend::OS::Solaris::Storages;
use strict;
#use warning;

#sd0      Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
#Vendor: HITACHI  Product: DK32EJ72NSUN72G  Revision: PQ08 Serial No: 43W14Z080040A34E
#Size: 73.40GB <73400057856 bytes>
#Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
#Illegal Request: 0 Predictive Failure Analysis: 0

sub check {
  `iostat 2>&1`;
  return if ($? >> 8)!=0;
  1;
}


sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $manufacturer;
  my $model;
  my $description;
  my $capacity;
  my $flag_first_line;

  foreach(`iostat -E`){
#print;
    if($flag_first_line){  		
      if(/^.*<(\S+)\s*bytes/){  			
	$capacity = $1;
	$capacity = $capacity/(1024*1024);
#print $capacity."\n";
      }
      $inventory->addStorages({
	  MANUFACTURER => $manufacturer,
	  MODEL => $model,
	  DESCRIPTION => $description,
	  TYPE => 'SCSI',
	  DISKSIZE => $capacity
	  });  		
    } 
    $flag_first_line = 0;	
    if(/^.*Product:\s*(\S+)/){
      $model = $1;
    }
    if(/^.*Serial No:\s*(\S+)/){
      $description = $1;
    }
    if(/^Vendor:\s*(\S+)/){
      $manufacturer = $1;
      $flag_first_line = 1;
    }

  }  
}

1;
