package Ocsinventory::Agent::Backend::OS::Linux::CPU;
use strict;

sub check { can_read("/proc/cpuinfo") }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

######### CPU
  my $processort;
  my $processorn;
  my $processors;
  
  my $bogomips;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processort = $2 if (/^(cpu|model\sname)\s*:\s*(.+)/i);
    $processort = $1 if (/^Processor\s+:\s*(.+)/); # ARM, Case sensitive!
    $processorn++ if (/^(processor|CPU\d+:\s+online)/i);
    $processors = $2 if (/^(clock|cpu\sMHz)\s*:\s*(\d+)(|\.\d+)$/i);
    $bogomips = $1 if (/^BogoMIPS\s+:\s+(\d+)/i); # ARM
  }
  close CPUINFO;

  # on some system (ARM, Sparc64), the CPU frequency is not in /proc/cpuinfo
  # whereas $clocktickfile seems to give the correct information
  my $clocktickfile = "/sys/devices/system/cpu/cpu0/clock_tick";
  if (-f $clocktickfile) {
    open CLOCKTICK, "<".$clocktickfile or warn;
    chomp (my $clocktick = <CLOCKTICK> );
    $processors = $1 if $clocktick =~ /^(\d+?)\d{6}$/; # 360010281
    close CLOCKTICK;
  }
  
  # BogoMIPS looks like the CPU frequency, at last on my Linksys NSLU2
  # Contact me if you have a better solution to get the information
  #    goneri@rulezlan.org
  $processors = $bogomips if !$processors;

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


}

1
