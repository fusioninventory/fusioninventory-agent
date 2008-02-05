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
    $processorn++ if (/^processor/);
    $processors = $2 if (/^(clock|cpu\sMHz)\s*:\s*(\d+)(|\.\d+)$/i);
  }
  close CPUINFO;

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


}

1
