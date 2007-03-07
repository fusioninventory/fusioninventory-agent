package Ocsinventory::Agent::Backend::OS::BSD::CPU;
use strict;

sub check {
  return unless -r "/dev/mem";

  `which dmidecode 2>&1`;
  return if ($? >> 8)!=0;
  `dmidecode 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $processort;
  my $processorn;
  my $processors;
  
  my $family;
  my $manufacturer;

# XXX Parsing dmidecode output using "type 4" section
# for nproc type and speed
# because no /proc on *BSD
  my $flag=0;
  my $status=0; ### XXX 0 if Unpopulated
  for(`dmidecode`){
    $flag=1 if /dmi type 4,/i;
    if((/dmi type (\d+),/i) && ($flag)){
      if ($status){
        $status=0;
        $processorn++;
      }
      last if ($1!='4');
    }
    
    $status = 1 if $flag && /^\s*status\s*:.*enabled/i;
    $family = $1 if $flag && /^\s*family\s*:\s*(.*)/i;
    $manufacturer = $1 if $flag && /^\s*manufacturer\s*:\s*(.*)/i;
    $processors = $1 if $flag && /^\s*current speed\s*:\s*(\d+).+/i;
    $processort = "$manufacturer $family" if $manufacturer && $family;
  }
  
  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });

}
1;
