package Ocsinventory::Agent::Backend::OS::Linux::Archs::I386;
use strict;

sub check { 
  return unless -r "/proc/cpuinfo";
  my $arch = `arch`;
  return unless $arch =~ /^(i[3456]86|amd64|x86_64)/;
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
  open CPUINFO, "</tmp/cpuinfo" or warn;
  foreach(<CPUINFO>){
    $processorn++ if (/^processor\s*:/);
    if (/^model name\s*:\s*(.+)/i) {
        $processort = $1; 
        $processort =~ s/\s+/ /g;
    }
    if (/^cpu mhz\s*:\s*([\.\d]+)\n/i) {
        $processors = $1;
        $processors =~ s/\.\d+//;
    }
  }
  close CPUINFO;

  
  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });

}

1
