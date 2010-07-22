package FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU;

use strict;

sub isInventoryEnabled {
  my $params = shift;

  my $logger = $params->{logger};

  if (!can_run ("memconf")) {
    $logger->debug('memconf not found in $PATH');
    return;
  }

  1;
}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  #modif 20100329
  my @cpu;
  my $current;
  my $cpu_core;
  my $cpu_thread;
  my $cpu_slot;
  my $cpu_speed;
  my $cpu_type;
  my $OSLevel;
  my $model;
  my $zone;
  my $sun_class_cpu=0;

  $OSLevel=`uname -r`;


  if ( $OSLevel =~ /5.8/ ){
	$zone = "global";
  }else{
	  foreach (`zoneadm list -p`){
		$zone=$1 if /^0:([a-z]+):.*$/;
	  }
  }

  if ($zone)
  {
  # first, we need determinate on which model of Sun Server we run,
  # because prtdiags output (and with that memconfs output) is differend
  # from server model to server model
  # we try to classified our box in one of the known classes
	$model=`uname -i`;
  # debug print model
  # cut the CR from string model
	$model = substr($model, 0, length($model)-1);
  }else{
	$model="Solaris Containers";
  }

  #print "CPU Model: $model\n";
  # we map (hopfully) our server model to a known class
  #
  #	#sun_class_cpu	sample out from memconf
  #     0               (default)		generic detection with prsinfo
  #	1               Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)
  #	2               Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)
  #	3               Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)
  #	4		Sun Microsystems, Inc. SPARC Enterprise T5220 (4-core 8-thread UltraSPARC-T2 1165MHz)
  #
  #if ($model eq "SUNW,Sun-Fire-280R") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-480R") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V240") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V245") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V250") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V440") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V445") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-880") { $sun_class_cpu = 1; }
  #if ($model eq "SUNW,Sun-Fire-V490") { $sun_class_cpu = 2; }
  #if ($model eq "SUNW,Netra-T12") { $sun_class_cpu = 2; }
  #if ($model eq "SUNW,Sun-Fire-T200") { $sun_class_cpu = 3; }
  #if ($model eq "SUNW,SPARC-Enterprise-T1000") { $sun_class_cpu = 4; }
  #if ($model eq "SUNW,SPARC-Enterprise-T5220") { $sun_class_cpu = 4; }
  #if ($model eq "SUNW,SPARC-Enterprise-T5240") { $sun_class_cpu = 4; }
  #if ($model eq "SUNW,SPARC-Enterprise-T5120") { $sun_class_cpu = 4; }
  #if ($model eq "SUNW,SPARC-Enterprise") { $sun_class_cpu = 4; }
  if ($model  =~ /SUNW,SPARC-Enterprise/) { $sun_class_cpu = 5; } # M5000
  if ($model  =~ /SUNW,SPARC-Enterprise-T\d/){ $sun_class_cpu = 4; } #T5220 - T5210
  if ($model  =~ /SUNW,Netra-T/){ $sun_class_cpu = 2; }
  if ($model  =~ /SUNW,Sun-Fire-\d/){ $sun_class_cpu = 1; }
  if ($model  =~ /SUNW,Sun-Fire-V/){ $sun_class_cpu = 2; }
  if ($model  =~ /SUNW,Sun-Fire-T\d/) { $sun_class_cpu = 3; }
  if ($model  =~ /Solaris Containers/){ $sun_class_cpu = 6; }



  if($sun_class_cpu == 0)
  {
  # if our maschine is not in one of the sun classes from upside, we use psrinfo
	# a generic methode
    foreach (`psrinfo -v`)
    {
      if (/^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/)
      {
        $cpu_type = $1;
        $cpu_speed = $2;
        $cpu_slot++;
      }
    }
  }

  if($sun_class_cpu == 1)
  {

  # Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)
    foreach (`memconf 2>&1`)
    {
      if(/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\d+)\s+X\s+(\S+)\s+(\d+)/)
      {
        $cpu_slot = $1;
        $cpu_type = $2;
        $cpu_speed = $3;
		$cpu_core=$1;
		$cpu_thread="0";
      }

      elsif (/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\S+)\s+(\d+)/)
      {
          $cpu_slot="1";
          $cpu_type=$1;
          $cpu_speed=$2;
		  $cpu_core="1";
		$cpu_thread="0";
      }

    }
  }

  if($sun_class_cpu == 2)
  {

  #Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)
    foreach (`memconf 2>&1`)
    {
      if(/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\d+)\s+X\s+(\S+)\s+(\S+)\s+(\d+)/)
      {
        $cpu_slot = $1;
        $cpu_type = $3 . " (" . $2 . ")";
        $cpu_speed = $4;
		$cpu_core=$1;
		$cpu_thread=$2;
      }
	  elsif (/^Sun Microsystems, Inc. Sun Fire\s+V\S+\s+\((\d+)\s+X\s+(\S+)\s+(\d+)(\S+)/)
	  {
        $cpu_slot = $1;
        $cpu_type = $2 . " (" . $1 . ")";
        $cpu_speed = $3;
		$cpu_core=$1;
		$cpu_thread=$2;
      }
	  #	Sun Microsystems, Inc. Sun Fire V240 (UltraSPARC-IIIi 1002MHz)
      elsif (/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\S+)\s+(\d+)/)
      {
          $cpu_slot="1";
          $cpu_type=$1;
          $cpu_speed=$2;
		  $cpu_core="1";
		$cpu_thread="0";
      }

    }
  }

  if($sun_class_cpu == 3)
  {
    foreach (`memconf 2>&1`)
    {
	#Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)
	#Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (4-core quad-thread UltraSPARC-T1 1000MHz)
      if(/^Sun Microsystems, Inc.\s+\S+\s+\(\S+\s+\S+\s+\S+\)\s+\((\d+).*\s+(\S+)\s+(\S+)\s+(\d+)/)
      {
        # T2000 has only one cCPU
        $cpu_slot = $1;
        $cpu_type = $3 . " (" . $1 . " " . $2 . ")";
        $cpu_speed = $4;
		$cpu_core=$1;
		$cpu_thread=$2;
      }
    }
  }

  if($sun_class_cpu == 4)
  {

	foreach (`memconf 2>&1`)
    {

      #Sun Microsystems, Inc. SPARC Enterprise T5120 (8-core 8-thread UltraSPARC-T2 1165MHz)
	  #Sun Microsystems, Inc. SPARC Enterprise T5120 (4-core 8-thread UltraSPARC-T2 1165MHz)
	  if(/^Sun Microsystems, Inc\..+\((\d+)*(\S+)\s+(\d+)*(\S+)\s+(\S+)\s+(\d+)MHz\)/)
      {
        $cpu_slot = $1;
        $cpu_type = $1 . " (" . $3 . "" . $4 . ")";
        $cpu_speed = $6;
		$cpu_core=$1;
		$cpu_thread=$3;

      }
    }
  }

  if($sun_class_cpu == 5)
  {
    foreach (`memconf 2>&1`)
    {
      #Sun Microsystems, Inc. Sun SPARC Enterprise M5000 Server (6 X dual-core dual-thread SPARC64-VI 2150MHz)

	  #Fujitsu SPARC Enterprise M4000 Server (4 X dual-core dual-thread SPARC64-VI 2150MHz)
	  if(/^Sun Microsystems, Inc\..+\((\d+)\s+X\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)/)
      {
        $cpu_slot = $1;
        $cpu_type = $3 . " (" . $1 . " " . $2 . ")";
        $cpu_speed = $5;
		$cpu_core=$1." ".$2;
		$cpu_thread=$3;
      }
	  if(/^Fujitsu SPARC Enterprise.*\((\d+)\s+X\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)/)
      {
        $cpu_slot = $1;
        $cpu_type = $3 . " (" . $1 . " " . $2 . ")";
        $cpu_speed = $5;
		$cpu_core=$1." ".$2;
		$cpu_thread=$3;
      }

    }
  }


  if($sun_class_cpu == 6)
  {
	foreach (`prctl -n zone.cpu-shares $$`)
	{
		$cpu_type = $1 if /^zone.(\S+)$/;
		$cpu_type = $cpu_type." ".$1 if /^\s*privileged+\s*(\d+).*$/;
		#$cpu_slot = 1 if /^\s*privileged+\s*(\d+).*$/;
		foreach (`memconf 2>&1`)
		{
			if(/^.*\s+\((\d+).*\s+(\d+)MHz.*$/)
			{
				$cpu_slot = $1;
				$cpu_speed = $2;
			}
		}
	}
  }

  # for debug only
  print "cpu_slot: " . $cpu_slot . "\n";
  print "cpu_type: " . $cpu_type . "\n";
  print "cpu_speed: " . $cpu_speed . "\n";
  print "cpu_core: " . $cpu_core . "\n";
  print "cpu_thread: " . $cpu_thread . "\n";

  $current->{MANUFACTURER} = "SPARC" ;
  $current->{SPEED} = $cpu_speed if $cpu_speed;
  $current->{TYPE} = $cpu_type if $cpu_type;
	$current->{NUMBER} = $cpu_slot if $cpu_slot;
	$current->{CORE} = $cpu_core if $cpu_core;
	$current->{THREAD} = $cpu_thread if $cpu_thread;
  $inventory->addCPU($current);



  # insert to values we have found
 # $inventory->setHardware({
   #   PROCESSORT => $cpu_type,
     #PROCESSORN => $cpu_slot,
     # PROCESSORS => $cpu_speed
     # });

}
#run();
1;
