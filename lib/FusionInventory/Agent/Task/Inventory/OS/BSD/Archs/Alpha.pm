package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Alpha;

use strict;

sub isInventoryEnabled{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    $arch eq "alpha";
}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
  my ( $processort , $processorn , $processors );

  ### Get system model with "sysctl hw.model"
  #
  # example on *BSD
  # hw.model = AlphaStation 255 4/232

  chomp($SystemModel=`sysctl -n hw.model`);
  $SystemManufacturer = "DEC";

  ### Get processor type and speed in dmesg
  #
  # NetBSD:    AlphaStation 255 4/232, 232MHz, s/n
  #            cpu0 at mainbus0: ID 0 (primary), 21064A-2
  # OpenBSD:   AlphaStation 255 4/232, 232MHz
  #            cpu0 at mainbus0: ID 0 (primary), 21064A-2 (pass 1.1)
  # FreeBSD:   AlphaStation 255 4/232, 232MHz
  #            CPU: EV45 (21064A) major=6 minor=2

  for (`dmesg`) {
      if (/^cpu[^:]*:\s*(.*)$/i) { $processort = $1; }
      if (/$SystemModel,\s*(\S+)\s*MHz.*$/) { $processors = $1; }
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
