package Ocsinventory::Agent::Backend::OS::BSD::CPU;
use strict;

sub check {1};

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $processort;
  my $processorn;
  my $processors;
  
  my $family;
  my $manufacturer;
  my $nbproc;
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
    
    $status = 1 if $flag && /^status\s*:.*enabled/i;
    $family = $1 if $flag && /^family\s*:\s*(.*)/i;
    $manufacturer = $1 if $flag && /^manufacturer\s*:\s*(.*)/i;
    $processors = $1 if $flag && /^current speed\s*:\s*(\d+).+/i;
    $processort = "$manufacturer $family" if $manufacturer && $family;
  }
  
  # XXX if no dmidecode
  unless ($flag) {
  # XXX number of procs with sysctl (hw.ncpu)
    chomp($nbproc=`sysctl -n hw.ncpu`);
    # XXX proc type with sysctl (hw.model)
    chomp($processort=`sysctl -n hw.model`);
    # XXX quick and dirty _attempt_ to get proc speed through dmesg
    for(`dmesg`){
      my $tmp;
      if (/^cpu\S*\s.*\D[\s|\(]([\d|\.]+)[\s|-]mhz/i) { # XXX unsure
        $tmp = $1;
        $tmp =~ s/\..*//;
        $processors=$tmp;
        last
      }
    }
  }
  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });

}
1;
