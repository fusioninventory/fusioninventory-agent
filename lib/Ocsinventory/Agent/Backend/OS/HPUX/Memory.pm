package Ocsinventory::Agent::Backend::OS::HPUX::Memory;
use strict;

sub check { $^O =~ /hpux/ }

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $capacity=0;
  my $caption;
  my $description;
  my $numslot;
  my $subnumslot;
  my $serialnumber;
  my $type;
  my @list_mem=`echo 'sc product mem;il'| /usr/sbin/cstm`;

  my $ok=0;

  if ( `uname -m` =~ /ia64/ )
  {
      for ( `echo 'sc product IPF_MEMORY;il' | /usr/sbin/cstm` )
      {
         if ( /\w+IMM\s+Location/ )
         {
	   ;
         }
         elsif ( /(\w+IMM)\s+(\w+)\s+(\S+)\s+(\w+IMM)\s+(\w+)\s+(\S+)/ )
         {
             $inventory->addMemories({
                   CAPACITY => $3,
                   CAPTION => $2 ,
                   NUMSLOTS => "1" ,
                   TYPE => $1,
			    });
             $inventory->addMemories({
                   CAPACITY => $6,
                   CAPTION => $5 ,
                   NUMSLOTS => "1" ,
                   TYPE => $4,
			    });
          } 
      }
  }
  else
  {
     for ( `echo 'sc product system;il' | /usr/sbin/cstm ` ) {
       if ( /FRU\sSource\s+=\s+\S+\s+\(memory/ ) {
          $ok=0;
          #print "FRU Source memory\n";
       }
       if ( /Source\s+Detail\s+=\s4/ ) {
         $ok=1;
         #print "Source Detail IMM\n";
       }
       if ( /Extender\s+Location\s+=\s+(\S+)/ ) {
         $subnumslot=$1;
         #print "Extended sub $subnumslot\n";
       };
       if ( /DIMMS\s+Rank\s+=\s+(\S+)/ ) {
         $numslot=sprintf("%02x",$1);
         #print "Num slot $numslot\n";
       }
    
       if ( /FRU\s+Name\.*:\s+(\S+)/ ) {
          if ( /(\S+)_(\S+)/ ) {
             $type=$1;
             $capacity=$2;
             #print "Type $type capa $capacity\n";
          }
          elsif ( /(\wIMM)(\S+)/ )
          {
             $ok=1;
             $type=$1;
             $numslot=$2;
             #print "Type $type numslot $numslot\n";
          }
       }
       if ( /Part\s+Number\.*:\s*(\S+)\s+/ ) {
         $description=$1;
         #print "ref $description\n";
       };
       if ( /Serial\s+Number\.*:\s*(\S+)\s+/ ) {
          $serialnumber=$1;
          if ( $ok eq 1 ) 
          {
             if ( $capacity eq 0 )
             {
                foreach ( @list_mem )
                {
                   if ( /\s+$numslot\s+(\d+)/ )
                   {
                      $capacity=$1;
                      #print "Capacity $capacity\n";
                   }
                }
             }
             $inventory->addMemories({
                   CAPACITY => $capacity,
	           CAPTION => "Ext $subnumslot Slot $numslot" ,
                   DESCRIPTION => "Part Number $description",
                   NUMSLOTS => "1" ,
		   SERIALNUMBER => $serialnumber,
                   TYPE => $type,
			    });
              $ok=0;
              $capacity=0;
	   };
          #print "Serial $serialnumber\n\n";
       };
     };
   }

}

1;
