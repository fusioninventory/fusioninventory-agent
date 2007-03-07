package Ocsinventory::Agent::Backend::OS::BSD::Archs::Sgimips;

use strict;

sub check{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    $arch eq "sgimips";
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
  my ( $processort , $processorn , $processors );

  # hw.model = SGI-IP22
  chomp($SystemModel=`sysctl -n hw.model`);
  $SystemManufacturer = "SGI";

  # in dmesg
  # mainbus0 (root): SGI-IP22 [SGI, 6906e152], 1 processor
  # cpu0 at mainbus0: MIPS R4400 CPU (0x450) Rev. 5.0 with MIPS R4010 FPC Rev. 0.0
  # int0 at mainbus0 addr 0x1fbd9880: bus 75MHz, CPU 150MHz
  for (`dmesg`) {
      if (/$SystemModel\s*\[\S*\s*(\S*)\]/) { $SystemSerial = $1; }
      if (/cpu0 at mainbus0:\s*(.*)$/) { $processort = $1; }
      if (/CPU\s*(\S+)\s*MHz/) { $processors = $1; }
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
