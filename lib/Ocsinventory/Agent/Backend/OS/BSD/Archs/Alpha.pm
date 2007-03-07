package Ocsinventory::Agent::Backend::OS::BSD::Archs::Alpha;

use strict;

sub check{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    $arch eq "alpha";
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
  my ( $processort , $processorn , $processors );

  # hw.model = AlphaStation 255 4/232
  chomp($SystemModel=`sysctl -n hw.model`);
  $SystemManufacturer = "DEC";

  # in dmesg
  # cpu0 at mainbus0: ID 0 (primary), 21064A-2
  for (`dmesg`) {
      if (/^cpu0 at mainbus0:\s*(.*)$/) { $processort = $1; }
      if (/$SystemModel,\s*(\S+)\s*MHz.*$/) { $processors = $1; }
  }
  

  # XXX number of procs with sysctl (hw.ncpu)
  chomp($processorn=`sysctl -n hw.ncpu`);

# Writing data
  $inventory->setBios ({
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
      BMANUFACTURER => $BiosManufacturer,
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
    });

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


}

1;
