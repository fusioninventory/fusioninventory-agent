package Ocsinventory::Agent::Backend::OS::Solaris::CPU;


#========================= CPUs ===============================================
#
#            CPU      Run    E$   CPU      CPU
#FRU Name    ID       MHz    MB   Impl.    Mask
#----------  -------  ----  ----  -------  ----
#/N0/SB0/P0    0      1200   8.0  US-III+  11.0
#/N0/SB0/P1    1      1200   8.0  US-III+  11.0
#/N0/SB0/P2    2      1200   8.0  US-III+  11.0
#/N0/SB0/P3    3      1200   8.0  US-III+  11.0

# it seems there is an other column "Module" between 
# CPU ID and Run MHZ on some solaris versions


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
  my $cpu_type;
  my $cpu_slot;
  my $cpu_speed;
  my $cpu_type;

  my $flag;
  my $flag_cpu;

  my $freq = 2;
  my $type = 4;

  foreach(`prtdiag`) {
#print $_."\n";
    last if(/^\=+/ && $flag_cpu);
    next if(/^\s+/ && $flag_cpu);

    # parse the header line : "FRU_Name    ID       MHz    MB   Impl.    Mask"
    if ($flag_cpu && (s/^FRU Name/FRU_Name/ || /^Brd/)) {
      my $index = 0;
      foreach (split(/\S+/)) {
        $freq = $index if ($_ == 'MHz');
        $type = $index if ($_ == 'Impl.');
        $index++;
      }
    }
    
    if($flag && $flag_cpu && /^\S+\s+(\S+)/){
      $cpu_slot++;  	  
    }
    my $reggroup = "\\S+\\s+"x$freq;
    if($flag && $flag_cpu && /^$reggroup(\S+)/){
      $cpu_speed = $1;  	
    }
    $reggroup = "\\S+\\s+"x$type;
    if($flag && $flag_cpu && /^$reggroup(\S+)/){
      $cpu_type = $1;  	  
    }
#if($flag && $flag_cpu){print "CPU  type= ".$cpu_type." CPU speed=".$cpu_speed." CPU slot=".$cpu_slot."\n";}

    if(/^=+\s+CPU/){$flag_cpu = 1;}	
    if($flag_cpu && /^-+/){$flag = 1;} 
  }

  $inventory->setHardware({
      PROCESSORT => $cpu_type,
      PROCESSORN => $cpu_slot,
      PROCESSORS => $cpu_speed

      });

}

1;
