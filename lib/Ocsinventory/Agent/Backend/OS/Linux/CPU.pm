package Ocsinventory::Agent::Backend::OS::Linux::CPU;
use strict;

sub check { 
  return unless -r "/proc/cpuinfo";
  1; 
};

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

######### CPU
  my $processort;
  my $processorn;
  my $processors;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processort = $2 if (/^(cpu|model\sname)\s*:\s*(.+)/i);
    $processorn++ if (/^processor|CPU\d+:\s+online/);
    $processors = $2 if (/^(clock|cpu\sMHz)\s*:\s*(\d+)(|\.\d+)$/i);
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

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


}

1
