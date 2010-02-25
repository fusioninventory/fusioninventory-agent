package FusionInventory::Agent::Task::Inventory::OS::HPUX::CPU;
                                                                                                   
###                                                                                                
# Version 1.1                                                                                      
# Correction of Bug n 522774                                                                       
#                                                                                                  
# thanks to Marty Riedling for this correction                                                     
#                                                                                                  
###                                                                                                

sub isInventoryEnabled  { $^O =~ /hpux/ }

sub doInventory {
   my $params = shift;
   my $inventory = $params->{inventory};

   my $processort;
   my $processorn;
   my $processors="";
   my $DeviceType;
   my $cpuInfo;
   my $serie;

   # Using old system HpUX without machinfo
   # the Hpux whith machinfo will be done after
   my %cpuInfos = (
                "D200"=>"7100LC 75",
                "D210"=>"7100LC 100",
                "D220"=>"7300LC 132",
                "D230"=>"7300LC 160",
                "D250"=>"7200 100",
                "D260"=>"7200 120",
                "D270"=>"8000 160",
                "D280"=>"8000 180",
                "D310"=>"7100LC 100",
                "D320"=>"7300LC 132",
                "D330"=>"7300LC 160",
                "D350"=>"7200 100",
                "D360"=>"7200 120",
                "D370"=>"8000 160",
                "D380"=>"8000 180",
                "D390"=>"8200 240",
                "K360"=>"8000 180",
                "K370"=>"8200 200",
                "K380"=>"8200 240",
                "K400"=>"7200 100",
                "K410"=>"7200 120",
                "K420"=>"7200 120",
                "K460"=>"8000 180",
                "K570"=>"8200 200",
                "K580"=>"8200 240",
                "L1000-36"=>"8500 360",
                "L1500-7x"=>"8700 750",
                "L3000-7x"=>"8700 750",
                "N4000-44"=>"8500 440",
                "ia64 hp server rx1620"=>"itanium 1600");

   if (can_run("machinfo"))
   {
      foreach ( `machinfo`)
      {
         if ( /Number of CPUs\s+=\s+(\d+)/ )
         {
            $processorn=$1;
         }
         if ( /Clock speed\s+=\s+(\d+)\s+MHz/ )
         {
            $processors=$1;
         }
         # Added for HPUX 11.31
	 if ( /Intel\(R\) Itanium 2 9000 series processor \((\d+\.\d+)/ || /Intel\(R\) Itanium 2 9000 series processors \((\d+\.\d+)/ )
         {
            $processors=$1*1000;
         }
         if ( /(\d+)\s+logical processors/ )
         {
            $processorn=$1;
         }
         # end HPUX 11.31
      }
   }
   else
   {
      chomp($DeviceType =`model |cut -f 3- -d/`);
      my $cpuInfo = $cpuInfos{"$DeviceType"};
      if ( "$cpuInfo" =~ /^(\S+)\s(\S+)/ ) 
      {
         $processort=$1;
         $processors=$2;
      } 
      else 
      {
        for ( `echo 'sc product cpu;il' | /usr/sbin/cstm | grep "CPU Module"` ) 
        {
	   if ( /(\S+)\s+CPU\s+Module/ ) 
           {
             $processort=$1;
           }
        };
        for ( `echo 'itick_per_usec/D' | adb -k /stand/vmunix /dev/kmem` )
        {
            if ( /tick_per_usec:\s+(\d+)/ )
	    {
	       $processors=$1;
            }
        }
      };
      # NBR CPU
      chomp($processorn=`ioscan -Fk -C processor | wc -l`);
      #print "HP $processort A $processorn A $processors ";
   }

   chomp($serie = `uname -m`);
   if ( $serie =~ /ia64/) 
   {
      $processort="Itanium"
   }
   if ( $serie =~ /9000/) 
   {
      $processort="PA$processort";
   }
   $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors,
    });


}

1;
