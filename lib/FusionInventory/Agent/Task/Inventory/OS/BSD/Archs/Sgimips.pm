package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Sgimips;

use strict;

sub isInventoryEnabled{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    $arch =~ m/^sgi/; 
}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
  my ( $processort , $processorn , $processors );

  ### Get system model with "sysctl hw.model"
  #
  # example on NetBSD
  # hw.model = SGI-IP22
  # example on OpenBSD
  # hw.model=SGI-O2 (IP32)

  chomp($SystemModel=`sysctl -n hw.model`);
  $SystemManufacturer = "SGI";

  ### Get processor type and speed in dmesg
  #
  # Examples of dmesg output :
  #
  # I) Indy
  # a) NetBSD
  # mainbus0 (root): SGI-IP22 [SGI, 6906e152], 1 processor
  # cpu0 at mainbus0: MIPS R4400 CPU (0x450) Rev. 5.0 with MIPS R4010 FPC Rev. 0.0
  # int0 at mainbus0 addr 0x1fbd9880: bus 75MHz, CPU 150MHz
  #
  # II) O2
  # a) NetBSD
  # mainbus0 (root): SGI-IP32 [SGI, 8], 1 processor
  # cpu0 at mainbus0: MIPS R5000 CPU (0x2321) Rev. 2.1 with built-in FPU Rev. 1.0
  # b) OpenBSD
  # mainbus0 (root)
  # cpu0 at mainbus0: MIPS R5000 CPU rev 2.1 180 MHz with R5000 based FPC rev 1.0
  # cpu0: cache L1-I 32KB D 32KB 2 way, L2 512KB direct

  for (`dmesg`) {
      if (/$SystemModel\s*\[\S*\s*(\S*)\]/) { $SystemSerial = $1; }
      if (/cpu0 at mainbus0:\s*(.*)$/) { $processort = $1; }
      if (/CPU\s*.*\D(\d+)\s*MHz/) { $processors = $1; }
  }
  
  # number of procs with sysctl (hw.ncpu)
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
