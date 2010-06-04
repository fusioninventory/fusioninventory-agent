package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

# Parsing dmidecode output
# Using "type 0" section
  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate, $YEAR, $MONTH, $DAY, $HOUR, $MIN, $SEC, $AssetTag);

  my $vmsystem;

  my @dmidecode = `dmidecode`;
  s/^\s+// for (@dmidecode);

  # get the BIOS values
  my $flag=0;
  for(@dmidecode){
    $flag=1 if /dmi type 0,/i;
    last if($flag && (/dmi type (\d+),/i) && ($1!=0));
    if((/^vendor:\s*(.+?)(\s*)$/i) && ($flag)) {
        $BiosManufacturer = $1;
        if ($BiosManufacturer =~ /(QEMU|Bochs)/i) {
            $vmsystem = 'QEMU';
        } elsif ($BiosManufacturer =~ /VirtualBox/i) {
            $vmsystem = 'VirtualBox';
        } elsif ($BiosManufacturer =~ /^Xen/i) {
            $vmsystem = 'Xen';
        }

    }
    if((/^release\ date:\s*(.+?)(\s*)$/i) && ($flag)) { $BiosDate = $1 }
    if((/^version:\s*(.+?)(\s*)$/i) && ($flag)) { $BiosVersion = $1 }
  }
 
  # Try to query the machine itself 
  $flag=0;
  for(@dmidecode){
    if(/dmi type 1,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=1));
    if((/^serial number:\s*(.+?)(\s*)$/i) && ($flag)) { $SystemSerial = $1 }
    if((/^(product name|product):\s*(.+?)(\s*)$/i) && ($flag)) {
        $SystemModel = $2;
        if ($SystemModel =~ /VMware/i) {
            $vmsystem = 'VMware';
        } elsif ($SystemModel =~ /Virtual Machine/i) {
            $vmsystem = 'Virtual Machine';
        }
    }
    if((/^(manufacturer|vendor):\s*(.+?)(\s*)$/i) && ($flag)) { $SystemManufacturer = $2 }
  }

  # Failback on the motherbord
  $flag=0;
  for(@dmidecode){
    if(/dmi type 2,/i){$flag=1;}
    last if($flag && (/dmi type (\d+),/i) && ($1!=2));
    if((/^serial number:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemSerial)) { $SystemSerial = $1 }
    if((/^product name:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemModel)) { $SystemModel = $1 }
    if((/^manufacturer:\s*(.+?)(\s*)/i) && ($flag) && (!$SystemManufacturer)) { $SystemManufacturer = $1 }
  }

  $flag=0;
  for(@dmidecode){
      if ($flag) {
          if (/^Asset Tag:\s*(.+\S)/i) {
              $AssetTag = $1;
              $AssetTag = '' if $AssetTag eq 'Not Specified';
              last;
          } elsif (/dmi type \d+,/i) {  # End of the section
              last;
          }
      }
      if (/dmi type 3,/i) {
          $flag=1;
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
    });

    if ($vmsystem) {
        $inventory->setHardware ({
            VMSYSTEM => $vmsystem,
        });
    }


}

1;
