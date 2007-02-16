package Ocsinventory::Agent::Backend::OS::Solaris::Memory;

#========================= Memory Configuration ===============================
#
#                     Logical  Logical  Logical
#               Port  Bank     Bank     Bank         DIMM    Interleave  Interlea                                              ve
#FRU Name        ID   Num      Size     Status       Size    Factor      Segment
#-------------  ----  ----     ------   -----------  ------  ----------  --------                                              --
#/N0/SB0/P0/B0    0    0      1024MB    pass          512MB     8-way       0
#/N0/SB0/P0/B0    0    2      1024MB    pass          512MB     8-way       0
#/N0/SB0/P1/B0    1    0      1024MB    pass          512MB     8-way       0
#/N0/SB0/P1/B0    1    2      1024MB    pass          512MB     8-way       0
#/N0/SB0/P2/B0    2    0      1024MB    pass          512MB     8-way       0
#/N0/SB0/P2/B0    2    2      1024MB    pass          512MB     8-way       0
#/N0/SB0/P3/B0    3    0      1024MB    pass          512MB     8-way       0
#/N0/SB0/P3/B0    3    2      1024MB    pass          512MB     8-way       0
#
#========================= IO Cards =========================



use strict;

sub check {
  `prtdiag 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};
  
  my @prtdiag;
  my $capacity;
  my $description;
  my $numslots;
  my $speed;
  my $type;
  my $bank;
  
  my $flag;
  my $flag_mem;

  foreach(`prtdiag`) {  	
  	last if(/^\=+/ && $flag_mem);
  	next if(/^\s+/ && $flag_mem);
  	if($flag && $flag_mem && /^(\S+)\s/){  	
  	  $description = $1;  	  
  	}
  	if($flag && $flag_mem && /^\S+\s+(\S+)/){ 
  	  #TO DO if numslots = 0 then data send to server is "??" ! 	 
  	  $numslots = $1;  	  
  	}
  	if($flag && $flag_mem && /^\S+\s+\S+\s+\S+\s+(\S+)/){  	  
  	  $capacity = $1; 	  
  	}  	
  	if($flag && $flag_mem){
  	  $inventory->addMemories({
		CAPACITY => $capacity,	
	  	DESCRIPTION => $description,
	  	NUMSLOTS => $numslots,
	  	#TO DO Speed and type
	  	#SPEED => $speed,
	  	#TYPE => $type,
	  })	
	}
	if(/^\=+\s+Memory Configuration\s+=+/){$flag_mem = 1;}	
  	if($flag_mem && /^-+/){$flag = 1;}
  }  	
}

1;
