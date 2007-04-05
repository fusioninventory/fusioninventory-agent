package Ocsinventory::Agent::Backend::OS::Linux::Archs::I386;
use strict;

sub check { 
  return unless -r "/proc/cpuinfo";
  my $arch = `arch`;
  return unless $arch =~ /^(i[3456]86|amd64)/;
  1; 
};

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
# TODO Need to be able to register different CPU speed!

  my $processort;
  my $processorn;
  my $processors;
  my $arch;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processorn++ if (/^processor\s*:/);
    $processort = $1 if (/^model name\s*:\s*(.+)/i);
    $processors = $1 if (/^cpu mhz\s*:\s*(\S+?)(|\.\d+)\n/i);
  }
  close CPUINFO;
  
  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });

}

1
