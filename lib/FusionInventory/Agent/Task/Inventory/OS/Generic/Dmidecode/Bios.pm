package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate, $AssetTag, $MotherboardManufacturer, $MotherboardModel, $MotherboardSerial );

  #System DMI
  $SystemManufacturer = `dmidecode -s system-manufacturer`;
  $SystemModel = `dmidecode -s system-product-name`;
  $SystemSerial = `dmidecode -s system-serial-number`;
  $AssetTag = `dmidecode -s chassis-asset-tag`;
  
  chomp($SystemModel);
  $SystemModel =~ s/\s+$//g;
  chomp($SystemManufacturer);
  $SystemManufacturer =~ s/\s+$//g;
  chomp($SystemSerial);
  $SystemSerial =~ s/\s+$//g;
  chomp($AssetTag);
  $AssetTag =~ s/\s+$//g;
  
  #Motherboard DMI
  $MotherboardManufacturer = `dmidecode -s baseboard-manufacturer`;
  $MotherboardModel = `dmidecode -s baseboard-product-name`;
  $MotherboardSerial = `dmidecode -s baseboard-serial-number`;
  
  chomp($MotherboardModel);
  $MotherboardModel =~ s/\s+$//g;
  chomp($MotherboardManufacturer);
  $MotherboardManufacturer =~ s/\s+$//g;
  chomp($MotherboardSerial);
  $MotherboardSerial =~ s/\s+$//g;
  
  #BIOS DMI
  $BiosManufacturer = `dmidecode -s bios-vendor`;
  $BiosVersion = `dmidecode -s bios-version`;
  $BiosDate = `dmidecode -s bios-release-date`;
  
  chomp($BiosManufacturer);
  $BiosManufacturer =~ s/\s+$//g;
  chomp($BiosVersion);
  $BiosVersion =~ s/\s+$//g;
  chomp($BiosDate);
  $BiosDate =~ s/\s+$//g;

# Some bioses don't provide a serial number so I check for CPU ID (e.g: server from dedibox.fr)
  my @cpu;
  if (!$SystemSerial ||$SystemSerial =~ /^0+$/) {
    @cpu = `dmidecode -t processor`;
    for (@cpu){
      if (/ID:\s*(.*)/i){
        $SystemSerial = $1;
      }
    }
  }

# Writing data
  $inventory->setBios ({
      ASSETTAG => $AssetTag,
      SMANUFACTURER => $SystemManufacturer,
      SMODEL => $SystemModel,
      SSN => $SystemSerial,
      BMANUFACTURER => $BiosManufacturer,
      BVERSION => $BiosVersion,
      BDATE => $BiosDate,
      MMANUFACTURER => $MotherboardManufacturer,
      MMODEL => $MotherboardModel,
      MSN => $MotherboardSerial,
    });
}

1;
